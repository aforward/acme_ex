defmodule AcmeEx.Router do
  use Plug.Builder
  alias Plug.Conn
  alias AcmeEx.{Account, Order, Header, Jws, Nonce, Cert}

  @favicon File.read!("./assets/favicon.ico")

  def init(opts), do: opts |> Map.new()

  @doc """

  """
  def child_spec(args) do
    {Plug.Adapters.Cowboy2,
     scheme: :http, plug: {AcmeEx.Router, [site: site(args)]}, options: [port: port(args)]}
  end

  @doc """
  Determine the Acme `port` to run on.  This will default to 4002 if none provided.

  ## Examples

      iex> AcmeEx.Router.port([])
      4002

      iex> AcmeEx.Router.port([port: 4848])
      4848

  """
  def port(args), do: args[:port] || 4002

  @doc """
  Determine the Acme `site` URL.  You can provide this directly
  when you start the app using

  ## Examples

      iex> AcmeEx.Router.site([])
      "http://localhost:4002"

      iex> AcmeEx.Router.site([port: 4848])
      "http://localhost:4848"

      iex> AcmeEx.Router.site([site: "http://localhost:9999"])
      "http://localhost:9999"

  """
  def site(args), do: args[:site] || "http://localhost:#{port(args)}"

  def call(%Conn{request_path: "/"} = conn, _config) do
    send_resp(conn, 200, "hello world")
  end

  def call(%Conn{method: "HEAD", request_path: "/new" <> _} = conn, _config) do
    respond_body(conn, 405, "", [Header.nonce()])
  end

  def call(%Conn{method: "GET", request_path: "/directory"} = conn, config) do
    respond_json(conn, 200, %{
      newNonce: "#{config.site}/new-nonce",
      newAccount: "#{config.site}/new-account",
      newOrder: "#{config.site}/new-order",
      newAuthz: "#{config.site}/new-authz",
      revokeCert: "#{config.site}/revoke-cert",
      keyChange: "#{config.site}/key-change"
    })
  end

  def call(%Conn{method: "POST", request_path: "/new-account"} = conn, _config) do
    conn
    |> verify_request()
    |> Account.client_key()
    |> Account.new()
    |> (&respond_json(conn, 201, &1, [Header.nonce()])).()
  end

  def call(%Conn{method: "POST", request_path: "/new-order"} = conn, config) do
    conn
    |> verify_request()
    |> create_order()
    |> (fn {order, account} ->
          respond_json(
            conn,
            201,
            %{
              status: order.status,
              expires: Order.expires(),
              identifiers: Order.identifiers(order),
              authorizations: [Order.authorization(config, order, account)],
              finalize: Order.finalize(config, order, account)
            },
            [Header.location(config, order, account), Header.nonce()]
          )
        end).()
  end

  def call(%Conn{method: "GET", request_path: "/order/" <> path} = conn, config) do
    path
    |> Order.decode_path()
    |> (fn {order, account} -> Order.to_summary(config, order, account) end).()
    |> (&respond_json(conn, 200, &1)).()
  end

  def call(%Conn{method: "GET", request_path: "/authorizations/" <> path} = conn, config) do
    path
    |> Order.decode_path()
    |> (fn {order, account} ->
          respond_json(conn, 200, %{
            status: order.status,
            identifier: %{type: "dns", value: "localhost"},
            challenges: [Order.to_challenge(config, order, account)]
          })
        end).()
  end

  def call(%Conn{method: "POST", request_path: "/challenge/http/" <> path} = conn, config) do
    conn
    |> verify_order(path)
    |> (fn {request, {order, account}} ->
          {:ok, _pid} =
            AcmeEx.Challenge.start_verify(
              {order, account},
              config.dns,
              Account.thumbprint(request)
            )

          respond_json(conn, 200, Order.to_challenge(config, order, account), [
            Header.nonce(),
            Header.authorization(config, order, account)
          ])
        end).()
  end

  def call(%Conn{method: "POST", request_path: "/finalize/" <> path} = conn, config) do
    conn
    |> verify_order(path)
    |> (fn {request, {_order, account} = id} ->
          request
          |> Cert.generate!(id)
          |> update_cert(id)
          |> (&Order.to_summary(config, &1, account)).()
          |> (&respond_json(conn, 200, &1, [Header.nonce()])).()
        end).()
  end

  def call(%Conn{method: "GET", request_path: "/cert/" <> path} = conn, _config) do
    path
    |> Order.decode_path()
    |> (fn {order, _account} -> order.cert end).()
    |> (&respond_body(conn, 200, &1)).()
  end

  def call(%Conn{method: "GET", request_path: "/favicon.ico"} = conn, _config) do
    respond_body(conn, 200, @favicon, [{"content-type", "image/x-icon"}])
  end

  defp respond_json(conn, status, data, headers \\ []) do
    conn
    |> merge_resp_headers(headers)
    |> respond_body(
      status,
      Jason.encode!(data),
      [{"content-type", "application/json"}]
    )
  end

  defp respond_body(conn, status, body, headers \\ []) do
    conn
    |> merge_resp_headers(headers)
    |> send_resp(status, body)
  end

  defp verify_request(conn) do
    conn
    |> read_body!()
    |> Jws.decode()
    |> (fn {:ok, request} ->
          request
          |> get_in([:protected, "nonce"])
          |> Base.decode64!(padding: false)
          |> String.to_integer()
          |> Nonce.verify()

          request
        end).()
  end

  defp verify_order(conn, path) do
    conn
    |> verify_request()
    |> (&{&1, Order.decode_path(path)}).()
  end

  defp create_order(request) do
    request
    |> Account.client_key()
    |> Account.upsert()
    |> (fn account ->
          request
          |> Order.domains()
          |> Order.new(account)
          |> (&{&1, account}).()
        end).()
  end

  defp update_cert(cert, {order, account}) do
    account.id
    |> Order.update(%{order | cert: cert})
    |> case do
      {:ok, updated_order} -> updated_order
      {:error, reason} -> raise reason
    end
  end

  defp read_body!(conn) do
    conn
    |> read_body()
    |> (fn {:ok, body, _conn} -> body end).()
  end
end

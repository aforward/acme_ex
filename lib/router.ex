defmodule AcmeEx.Router do
  use Plug.Builder
  alias AcmeEx.{Account, Order, Header, Jws, Nonce, Cert}

  def init(opts), do: opts |> Map.new()

  def call(%Plug.Conn{request_path: "/"} = conn, _config) do
    send_resp(conn, 200, "hello world")
  end

  def call(%Plug.Conn{method: "HEAD", request_path: "/new" <> _} = conn, _config) do
    respond_body(conn, 405, "", [Header.nonce()])
  end

  def call(%Plug.Conn{method: "GET", request_path: "/directory"} = conn, config) do
    respond_json(conn, 200, %{
      newNonce: "#{config.site}/new-nonce",
      newAccount: "#{config.site}/new-account",
      newOrder: "#{config.site}/new-order",
      newAuthz: "#{config.site}/new-authz",
      revokeCert: "#{config.site}/revoke-cert",
      keyChange: "#{config.site}/key-change"
    })
  end

  def call(%Plug.Conn{method: "POST", request_path: "/new-account"} = conn, _config) do
    conn
    |> verify_request()
    |> Account.client_key()
    |> Account.new()
    |> (&respond_json(conn, 201, &1, [Header.nonce()])).()
  end

  def call(%Plug.Conn{method: "POST", request_path: "/new-order"} = conn, config) do
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

  def call(
        %Plug.Conn{method: "GET", request_path: "/authorizations/" <> order_path} = conn,
        config
      ) do
    order_path
    |> Order.decode_path()
    |> (fn {order, account} ->
          respond_json(conn, 200, %{
            status: order.status,
            identifier: %{type: "dns", value: "localhost"},
            challenges: [Order.to_challenge(config, order, account)]
          })
        end).()
  end

  def call(
        %Plug.Conn{method: "POST", request_path: "/finalize/" <> order_path} = conn,
        config
      ) do
    conn
    |> verify_order(order_path)
    |> (fn {request, {_order, account} = id} ->
          request
          |> Cert.generate!(id)
          |> update_cert(id)
          |> (&Order.to_summary(config, &1, account)).()
          |> (&respond_json(conn, 200, &1, [Header.nonce()])).()
        end).()
  end

  # Call the Plug.Static directly so we can keep the config
  # for the other calls
  def call(conn, _opts) do
    [at: "/", from: "assets", only_matching: ~w(favicon)]
    |> Plug.Static.init()
    |> (fn opts -> Plug.Static.call(conn, opts) end).()
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

  defp respond_body(conn, status, body, headers) do
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

  defp verify_order(conn, order_path) do
    conn
    |> verify_request()
    |> (&{&1, Order.decode_path(order_path)}).()
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

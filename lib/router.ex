defmodule AcmeEx.Router do
  use Plug.Builder
  require Logger
  alias Plug.Conn
  alias AcmeEx.{Account, Order, Header, Jws, Nonce, Cert}

  @moduledoc """
  The test ACME server.  Add this to your supervision tree
  by calling

      AcmeEx.Router.child_spec()

  Available opts include:

  * `adapter`   - Defaults based on which version of cowboy
  * `port`      - Defaults to `4002`
  * `site`      - Defaults to `http://localhost:{port}`
  * `dns`       - DNS lookups for where to actually route the calls

  For example, to run on a different port, you would call

      AcmeEx.Router.child_spec(port: 4003)

  """

  @favicon File.read!("./assets/favicon.ico")

  def init(opts), do: opts |> Map.new()

  @doc """
  Generate a child_spec to be supervised.  Available opts include:

  * `adapter` - Defaults based on which version of cowboy you are running
  * `port` - Defaults to `4002`
  * `site` - Defaults to `http://localhost:{port}`

  """
  def child_spec(opts \\ []) do
    {adapter(opts),
     scheme: :http,
     plug: {__MODULE__, [site: site(opts), dns: dns(opts)]},
     options: [port: port(opts)]}
  end

  @doc """
  Determine the web adapter to use.  It will default based on
  the version of cowboy you are using.

  ## Examples

      iex> AcmeEx.Router.adapter([])
      Plug.Adapters.Cowboy2

      iex> AcmeEx.Router.adapter([adapter: Plug.Adapters.Cowboy])
      Plug.Adapters.Cowboy

      iex> AcmeEx.Router.adapter([adapter: "Cowboy2"])
      Plug.Adapters.Cowboy2
  """
  def adapter(opts), do: opts[:adapter] |> resolve_adapter()

  @doc """
  Determine the Acme `port` to run on.  This will default to 4002 if none provided.

  ## Examples

      iex> AcmeEx.Router.port([])
      4002

      iex> AcmeEx.Router.port([port: 4848])
      4848

  """
  def port(opts), do: opts[:port] || 4002

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
  def site(opts), do: opts[:site] || "http://localhost:#{port(opts)}"

  @doc """
  The underlying DNS lookup, this is useful for routing records somewhere else for testing

  ## Examples

      iex> AcmeEx.Router.dns([])
      nil

      iex> AcmeEx.Router.dns(dns: %{"foo.bar" => fn -> "localhost:4848" end}) |> Map.keys()
      ["foo.bar"]

  """
  def dns(opts), do: opts[:dns]

  def call(%Conn{method: method, request_path: path} = conn, config) do
    conn
    |> read_body()
    |> (fn {:ok, body, conn} ->
          handle_call(conn, method, path, body, config)
        end).()
  end

  defp handle_call(conn, _, "/", _body, _config) do
    send_resp(conn, 200, "hello world")
  end

  defp handle_call(conn, "HEAD", "/new" <> _, _body, _config) do
    Logger.info(fn -> "HEAD /new" end)
    respond_body(conn, 405, "", [Header.nonce()])
  end

  defp handle_call(conn, "GET", "/directory", _body, config) do
    Logger.info(fn -> "GET /directory" end)

    respond_json(conn, 200, %{
      newNonce: "#{config.site}/new-nonce",
      newAccount: "#{config.site}/new-account",
      newOrder: "#{config.site}/new-order",
      newAuthz: "#{config.site}/new-authz",
      revokeCert: "#{config.site}/revoke-cert",
      keyChange: "#{config.site}/key-change"
    })
  end

  defp handle_call(conn, "POST", "/new-account", body, _config) do
    Logger.info(fn -> "POST /new-account" end)

    body
    |> verify_request()
    |> (fn
          {:error, reason} ->
            respond_error(conn, "malformed", reason)

          request ->
            request
            |> Account.client_key()
            |> Account.new()
            |> (&respond_json(conn, 201, &1, [Header.nonce()])).()
        end).()
  end

  defp handle_call(conn, "POST", "/new-order", body, config) do
    Logger.info(fn -> "POST /new-order" end)

    body
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

  defp handle_call(conn, "GET", "/order/" <> path, _body, config) do
    path
    |> Order.decode_path()
    |> (fn {order, account} -> Order.to_summary(config, order, account) end).()
    |> (&respond_json(conn, 200, &1)).()
  end

  defp handle_call(conn, "GET", "/authorizations/" <> path, _body, config) do
    Logger.info(fn -> "GET /authorizations/#{path}" end)

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

  defp handle_call(conn, "POST", "/challenge/http/" <> path, body, config) do
    Logger.info(fn -> "POST /challenge/http/#{path}" end)

    body
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

  defp handle_call(conn, "POST", "/finalize/" <> path, body, config) do
    Logger.info(fn -> "POST /finalize/#{path}" end)

    body
    |> verify_order(path)
    |> (fn {request, {_order, account} = id} ->
          request
          |> Cert.generate!(id)
          |> update_cert(id)
          |> (&Order.to_summary(config, &1, account)).()
          |> (&respond_json(conn, 200, &1, [Header.nonce()])).()
        end).()
  end

  defp handle_call(conn, "GET", "/cert/" <> path, _body, _config) do
    Logger.info(fn -> "GET /cert/#{path}" end)

    path
    |> Order.decode_path()
    |> (fn {order, _account} -> order.cert end).()
    |> (&respond_body(conn, 200, &1)).()
  end

  defp handle_call(conn, "GET", "/favicon.ico", _body, _config) do
    respond_body(conn, 200, @favicon, [{"content-type", "image/x-icon"}])
  end

  defp handle_call(conn, method, request_path, _body, _config) do
    Logger.info(fn -> "#{method} #{request_path} (unknown path)" end)
    respond_body(conn, 404, "Unable to resolve #{conn.request_path}")
  end

  defp respond_error(conn, type, reason) do
    conn
    |> respond_body(
      403,
      Jason.encode!(%{
        type: "urn:ietf:params:acme:error:#{type}",
        detail: reason
      }),
      [{"content-type", "application/json"}]
    )
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

  defp verify_request(body) do
    body
    |> Jws.decode()
    |> (fn
          {:ok, request} ->
            request
            |> get_in([:protected, "nonce"])
            |> Base.decode64!(padding: false)
            |> String.to_integer()
            |> Nonce.verify()

            request

          {:error, :empty} ->
            {:error, "No request was provided, unable to proceed."}
        end).()
  end

  defp verify_order(body, path) do
    body
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

  defp resolve_adapter(nil) do
    case Application.spec(:cowboy, :vsn) do
      '1.' ++ _ -> Plug.Adapters.Cowboy
      _ -> Plug.Adapters.Cowboy2
    end
  end

  defp resolve_adapter(name) when is_binary(name) do
    String.to_atom("Elixir.Plug.Adapters.#{name}")
  end

  defp resolve_adapter(name) when is_atom(name), do: name
end

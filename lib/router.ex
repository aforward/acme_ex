defmodule AcmeEx.Router do
  use Plug.Builder

  def init(opts), do: opts |> Map.new()

  def call(%Plug.Conn{request_path: "/"} = conn, _configs) do
    send_resp(conn, 200, "hello world")
  end

  def call(%Plug.Conn{method: "HEAD", request_path: "/new" <> _} = conn, _configs) do
    respond_body(conn, 405, "", [AcmeEx.Header.nonce()])
  end

  def call(%Plug.Conn{method: "GET", request_path: "/directory"} = conn, configs) do
    respond_json(conn, 200, %{
      newNonce: "#{configs.site}/new-nonce",
      newAccount: "#{configs.site}/new-account",
      newOrder: "#{configs.site}/new-order",
      newAuthz: "#{configs.site}/new-authz",
      revokeCert: "#{configs.site}/revoke-cert",
      keyChange: "#{configs.site}/key-change"
    })
  end

  def call(%Plug.Conn{method: "POST", request_path: "/new-account"} = conn, _configs) do
    conn
    |> verify_request()
    |> AcmeEx.Account.client_key()
    |> AcmeEx.Account.new()
    |> (&respond_json(conn, 201, &1, [AcmeEx.Header.nonce()])).()
  end

  # Call the Plug.Static directly so we can keep the configs
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
    |> AcmeEx.Jws.decode()
    |> (fn {:ok, request} ->
          request
          |> get_in([:protected, "nonce"])
          |> Base.decode64!(padding: false)
          |> String.to_integer()
          |> AcmeEx.Nonce.verify()

          request
        end).()
  end

  defp read_body!(conn) do
    conn
    |> read_body()
    |> (fn {:ok, body, _conn} -> body end).()
  end
end

defmodule AcmeEx.Router do
  use Plug.Builder

  def init(opts), do: opts |> Map.new()

  def call(%Plug.Conn{request_path: "/"} = conn, _configs) do
    send_resp(conn, 200, "hello world")
  end

  def call(%Plug.Conn{request_path: "/directory"} = conn, configs) do
    respond_json(conn, 200, %{
      newNonce: "#{configs.site}/new-nonce",
      newAccount: "#{configs.site}/new-account",
      newOrder: "#{configs.site}/new-order",
      newAuthz: "#{configs.site}/new-authz",
      revokeCert: "#{configs.site}/revoke-cert",
      keyChange: "#{configs.site}/key-change"
    })
  end

  # Call the Plug.Static directly so we can keep the configs
  # for the other calls
  def call(conn, _opts) do
    [at: "/", from: "assets", only_matching: ~w(favicon)]
    |> Plug.Static.init()
    |> (fn opts -> Plug.Static.call(conn, opts) end).()
  end

  defp respond_json(conn, status, data) do
    conn
    |> merge_resp_headers([{"content-type", "application/json"}])
    |> send_resp(status, Jason.encode!(data))
  end
end

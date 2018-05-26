defmodule AcmeEx.Router do
  use Plug.Builder

  def call(%Plug.Conn{request_path: "/"} = conn, _opts) do
    send_resp(conn, 200, "hello world")
  end

  # Call the Plug.Static directly so we can keep the opts
  # for the other calls
  def call(conn, _opts) do
    [at: "/", from: "assets", only_matching: ~w(favicon)]
    |> Plug.Static.init()
    |> (fn opts -> Plug.Static.call(conn, opts) end).()
  end
end

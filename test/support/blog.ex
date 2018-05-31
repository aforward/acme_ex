defmodule AcmeEx.Blog do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/.well-known/acme-challenge/goodtoken"} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "goodtoken.alwaysbad")
  end

  def call(conn, opts), do: AcmeEx.Website.call(conn, opts)
end

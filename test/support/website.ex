defmodule AcmeEx.Website do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{request_path: "/.well-known/acme-challenge/goodtoken"} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "goodtoken.goodthumb")
  end

  def call(%Plug.Conn{request_path: "/.well-known/acme-challenge/badtoken"} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "badtoken.badchallenge")
  end

  def call(%Plug.Conn{request_path: "/.well-known/acme-challenge/unknowntoken"} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "this is not the challenge you are looking for")
  end

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "no idea what you are asking for")
  end
end

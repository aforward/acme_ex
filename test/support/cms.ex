defmodule AcmeEx.Cms do
  import Plug.Conn

  def init(opts), do: opts
  def call(conn, opts), do: AcmeEx.Website.call(conn, opts)
end

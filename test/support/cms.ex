defmodule AcmeEx.Cms do
  def init(opts), do: opts
  def call(conn, opts), do: AcmeEx.Website.call(conn, opts)
end

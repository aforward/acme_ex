defmodule AcmeEx.Header do
  alias AcmeEx.{Nonce, Order}

  def nonce(), do: Nonce.new() |> nonce()

  def nonce(nonce) do
    {"replay-nonce", nonce |> Nonce.encode()}
  end

  def location(config, order, account) do
    {"location", Order.location(config, order, account)}
  end

  def authorization(config, order, account) do
    {"link", "<#{Order.authorization(config, order, account)}>;rel=\"up\""}
  end

  def filter(conn, name) do
    conn.resp_headers
    |> Enum.filter(fn {k, _v} -> k == name end)
  end
end

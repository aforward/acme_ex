defmodule AcmeEx.Header do
  def nonce(), do: AcmeEx.Nonce.new() |> nonce()

  def nonce(nonce) do
    {"replay-nonce", nonce |> AcmeEx.Nonce.encode()}
  end

  def filter(conn, name) do
    conn.resp_headers
    |> Enum.filter(fn {k, _v} -> k == name end)
  end
end

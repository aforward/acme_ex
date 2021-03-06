defmodule AcmeEx.Nonce do
  def new(), do: create() |> insert()

  def next(), do: create() |> follow()
  def follow(nonce), do: nonce + 1

  def verify(nonce) do
    case AcmeEx.Db.pop({:nonce, nonce}) do
      {ok, _} -> ok
    end
  end

  def encode(nonce), do: nonce |> to_string() |> Base.encode64(padding: false)

  def create(), do: :erlang.unique_integer([:positive, :monotonic])

  defp insert(nonce) do
    {:nonce, ^nonce} = AcmeEx.Db.create({:nonce, nonce})
    nonce
  end
end

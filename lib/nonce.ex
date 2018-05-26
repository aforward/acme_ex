defmodule AcmeEx.Nonce do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def new(), do: create() |> insert()

  def next(), do: new() + 1

  def verify(nonce) do
    key = {:nonce, nonce}

    case :ets.take(__MODULE__, key) do
      [{^key, _value}] -> :ok
      _ -> :error
    end
  end

  def encode(nonce), do: nonce |> to_string() |> Base.encode64(padding: false)

  defp create(), do: :erlang.unique_integer([:positive, :monotonic])

  defp insert(nonce) do
    case :ets.insert_new(__MODULE__, {{:nonce, nonce}, nil}) do
      true -> nonce
      false -> raise "Unable to store nonce #{nonce}"
    end
  end
end

defmodule AcmeEx.Db do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def create(key, obj \\ nil) do
    case :ets.insert_new(__MODULE__, {key, obj}) do
      true -> key
      false -> raise "Unable to store #{key |> Kernel.inspect()}"
    end
  end

  def reset(), do: :ets.delete_all_objects(__MODULE__)

  def store(key, obj), do: :ets.insert(__MODULE__, {key, obj})

  def fetch(key), do: :ets.lookup(__MODULE__, key) |> clean(key)

  def pop(key), do: :ets.take(__MODULE__, key) |> clean(key)

  defp clean(answer, key) do
    case answer do
      [{^key, value}] -> {:ok, value}
      _ -> {:error, "Unable to locate #{key |> Kernel.inspect()}"}
    end
  end
end

defmodule AcmeEx.Db do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def create(entity, id, obj \\ nil) do
    case :ets.insert_new(__MODULE__, {{entity, id}, obj}) do
      true -> id
      false -> raise "Unable to store #{entity} #{id}"
    end
  end

  def fetch(entity, id) do
    key = {entity, id}

    :ets.lookup(__MODULE__, key)
    |> clean(key)
  end

  def pop(entity, id) do
    key = {entity, id}

    :ets.take(__MODULE__, key)
    |> clean(key)
  end

  defp clean(answer, {entity, id} = key) do
    case answer do
      [{^key, value}] -> {:ok, value}
      _ -> {:error, "Unable to locate #{entity} #{id}"}
    end
  end

end

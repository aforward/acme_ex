defmodule AcmeEx.Db do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  def create(entity, id) do
    case :ets.insert_new(__MODULE__, {{entity, id}, nil}) do
      true -> id
      false -> raise "Unable to store #{entity} #{id}"
    end
  end

  def pop(entity, id) do
    key = {entity, id}

    case :ets.take(__MODULE__, key) do
      [{^key, value}] -> {:ok, value}
      _ -> {:error, "Unable to locate #{entity} #{id}"}
    end
  end
end

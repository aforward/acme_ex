defmodule AcmeEx.Account do
  def client_key(request), do: request.protected |> Map.fetch!("jwk")

  def new(client_key), do: create() |> insert(client_key)

  def fetch(client_key), do: AcmeEx.Db.fetch({:account, client_key})

  defp create() do
    %{id: :erlang.unique_integer([:positive, :monotonic]), status: :valid, contact: []}
  end

  defp insert(account, client_key) do
    AcmeEx.Db.create({:account, client_key}, account)
    account
  end
end

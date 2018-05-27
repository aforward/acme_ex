defmodule AcmeEx.Account do
  alias AcmeEx.Jws

  def client_key(request), do: request.protected |> Map.fetch!("jwk")
  def thumbprint(request), do: request |> client_key() |> Jws.thumbprint()

  def new(client_key), do: create() |> insert(client_key)

  def upsert(client_key) do
    case fetch(client_key) do
      {:ok, account} -> account
      {:error, _reason} -> new(client_key)
    end
  end

  def fetch(client_key), do: AcmeEx.Db.fetch({:account, client_key})

  defp create() do
    %{id: :erlang.unique_integer([:positive, :monotonic]), status: :valid, contact: []}
  end

  defp insert(account, client_key) do
    AcmeEx.Db.create({:account, client_key}, account)
    account
  end
end

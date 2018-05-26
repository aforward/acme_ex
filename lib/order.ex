defmodule AcmeEx.Order do
  def new(account, domains, token \\ nil), do: domains |> create(token) |> insert(account)

  def fetch(client_key, order_id) do
    client_key
    |> account_id()
    |> (&AcmeEx.Db.fetch({:order, &1, order_id})).()
  end

  defp create(domains, token) do
    %{
      id: :erlang.unique_integer([:positive, :monotonic]),
      status: :pending,
      cert: nil,
      domains: domains,
      token: token || Base.url_encode64(:crypto.strong_rand_bytes(16), padding: false)
    }
  end

  def update(client_key, order) do
    client_key
    |> account_id()
    |> (&AcmeEx.Db.store({:order, &1, order.id}, order)).()
  end

  defp insert(order, account) do
    AcmeEx.Db.create({:order, account.id, order.id}, order)
    order
  end

  defp account_id(client_key) do
    client_key
    |> AcmeEx.Account.fetch()
    |> case do
      {:ok, account} -> account.id
      _ -> raise "Unable to locate account #{client_key}"
    end
  end
end

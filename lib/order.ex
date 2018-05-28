defmodule AcmeEx.Order do
  alias AcmeEx.{Account, Db}

  def new(domains, account, token \\ nil), do: domains |> create(token) |> insert(account)

  def fetch(client_key_or_id, order_id) do
    client_key_or_id
    |> account_id()
    |> (&Db.fetch({:order, &1, order_id})).()
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

  def update(client_key_or_id, order) do
    client_key_or_id
    |> account_id()
    |> (&Db.store({:order, &1, order.id}, order)).()
    |> case do
      true -> {:ok, order}
      _ -> {:error, "Unable to update order #{client_key_or_id}/#{order.id}"}
    end
  end

  def domains(request) do
    request.payload
    |> Map.fetch!("identifiers")
    |> Enum.filter(&(Map.fetch!(&1, "type") == "dns"))
    |> Enum.map(&Map.fetch!(&1, "value"))
  end

  def identifiers(order), do: order.domains |> Enum.map(&%{type: "dns", value: &1})

  def location(config, order, account) do
    "#{config.site}/order/#{encode_path(order, account)}"
  end

  def authorization(config, order, account) do
    "#{config.site}/authorizations/#{encode_path(order, account)}"
  end

  def finalize(config, order, account) do
    "#{config.site}/finalize/#{encode_path(order, account)}"
  end

  def expires(duration \\ 3600, now \\ nil) do
    (now || NaiveDateTime.utc_now())
    |> NaiveDateTime.add(duration || 3600, :second)
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_iso8601()
  end

  def encode_path(order, account), do: "#{account.id}/#{order.id}"

  def decode_path(order_path) do
    order_path
    |> String.split("/")
    |> Enum.map(&String.to_integer(&1))
    |> (fn [account_id, order_id] ->
          {
            fetch(account_id, order_id) |> ok!,
            %{id: account_id}
          }
        end).()
  end

  def to_challenge(config, order, account) do
    %{
      type: "http-01",
      status: order.status,
      url: "#{config.site}/challenge/http/#{encode_path(order, account)}",
      token: order.token
    }
  end

  defp insert(order, account) do
    Db.create({:order, account.id, order.id}, order)
    order
  end

  defp account_id(id) when is_integer(id), do: id

  defp account_id(client_key) when is_binary(client_key) do
    client_key
    |> Account.fetch()
    |> case do
      {:ok, account} -> account.id
      _ -> raise "Unable to locate account #{client_key}"
    end
  end

  defp ok!({:ok, obj}), do: obj
end

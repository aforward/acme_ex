defmodule AcmeEx.Challenge do
  alias AcmeEx.Order

  def start_verify({order, account}, dns, thumbprint) do
    AcmeEx.ChallengeSupervisor
    |> Task.Supervisor.start_child(fn ->
      if verify_domains(order.domains, dns, order.token, thumbprint) do
        Order.update(account.id, %{order | status: :valid})
      else
        Process.exit(self(), "Verification of #{order.domains |> Kernel.inspect()} failed.")
      end
    end)
  end

  def await_all() do
    AcmeEx.ChallengeSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(&await_verify/1)
  end

  def await_verify({:ok, pid}), do: await_verify(pid)

  def await_verify(pid) do
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, _, _, _} -> :ok
    end
  end

  def verify_domains(domains, dns, token, thumbprint) do
    domains
    |> Task.async_stream(fn domain ->
      domain
      |> server(dns)
      |> verify_server(token, thumbprint)
    end)
    |> Enum.map(fn
      {:ok, result} -> result
      _ -> :error
    end)
    |> Enum.all?(&(&1 == :ok))
  end

  defp verify_server(server, token, thumbprint) do
    server
    |> request(token)
    |> match(token, thumbprint)
    |> (fn {ok, _msg} -> ok end).()
  end

  def request(server, token) do
    :httpc.request(
      :get,
      {'http://#{server}/.well-known/acme-challenge/#{token}', []},
      [],
      body_format: :binary
    )
  end

  defp match({:ok, {{_, 200, _}, _headers, reply}}, token, expected) do
    token
    |> challenge(expected)
    |> case do
      ^reply -> {:ok, "Matched on #{reply}"}
      other -> {:error, "Mistached and received #{other}"}
    end
  end

  defp match({:ok, {{_, status, _}, _headers, _reply}}, _token, _expected), do: {:error, status}
  defp match({:error, _reason} = error, _token, _expected), do: error

  defp challenge(token, thumbprint), do: "#{token}.#{thumbprint}"

  defp server(domain, dns) do
    case Map.fetch(dns, domain) do
      {:ok, resolver} -> resolver.()
      :error -> domain
    end
  end
end

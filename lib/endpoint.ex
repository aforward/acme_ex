defmodule AcmeEx.Endpoint do
  @doc """
  Convert an endpoint into localhost domains for local resolutions.
  """
  def dns(endpoint, config \\ []) do
    (domains(config[:domain]) ++ domains(config[:extra_domains]))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&{&1, fn -> "localhost:#{endpoint.config(:http) |> Keyword.fetch!(:port)}" end})
    |> Enum.into(%{})
  end

  defp domains(nil), do: []
  defp domains(all) when is_list(all), do: all
  defp domains(one) when is_binary(one), do: [one]
end

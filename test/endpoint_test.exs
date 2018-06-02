defmodule AcmeEx.EndpointTest do
  use ExUnit.Case, async: true
  alias AcmeEx.Endpoint

  defmodule MyApp.Endpoint do
    def config(:http), do: [port: 4010]
  end

  test "no domains" do
    assert Endpoint.dns(MyApp.Endpoint) == %{}
  end

  test "one domain" do
    dns = Endpoint.dns(MyApp.Endpoint, domain: "foo.bar")
    assert dns |> Map.keys() == ["foo.bar"]
    assert dns["foo.bar"].() == "localhost:4010"
  end

  test "many domain" do
    dns =
      Endpoint.dns(MyApp.Endpoint, domain: "foo.bar", extra_domains: ["www.foo.bar", "foo.net"])

    assert dns |> Map.keys() |> Enum.sort() == ["foo.bar", "foo.net", "www.foo.bar"]
    assert dns["foo.bar"].() == "localhost:4010"
    assert dns["www.foo.bar"].() == "localhost:4010"
    assert dns["foo.net"].() == "localhost:4010"
  end
end

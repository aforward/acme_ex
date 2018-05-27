defmodule AcmeEx.HeaderTest do
  use ExUnit.Case, async: true

  alias AcmeEx.{Header, Nonce}

  test "nonce" do
    assert {"replay-nonce", Nonce.encode(9)} == Header.nonce(9)
  end

  test "location" do
    assert {"location", "http://localhost:9999/order/10/11"} ==
             Header.location(%{site: "http://localhost:9999"}, %{id: 11}, %{id: 10})
  end

  test "authorization" do
    assert {"link", "<http://localhost:9999/authorizations/10/11>;rel=\"up\""} ==
             Header.authorization(%{site: "http://localhost:9999"}, %{id: 11}, %{id: 10})
  end
end

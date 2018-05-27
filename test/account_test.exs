defmodule AcmeEx.AccountTest do
  use ExUnit.Case, async: true

  test "new" do
    id = AcmeEx.Nonce.next()
    assert %{id: id, contact: [], status: :valid} == AcmeEx.Account.new("abc123")
    assert {:ok, %{id: id, contact: [], status: :valid}} == AcmeEx.Account.fetch("abc123")
  end

  test "client_key" do
    assert "jwk123" == AcmeEx.Account.client_key(%{protected: %{"jwk" => "jwk123"}})
  end
end

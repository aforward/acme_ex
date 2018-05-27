defmodule AcmeEx.AccountTest do
  use ExUnit.Case, async: true

  alias AcmeEx.Account

  test "new OK" do
    id = AcmeEx.Nonce.next()
    assert %{id: id, contact: [], status: :valid} == Account.new("AcmeEx.AccountTest.abc123")

    assert {:ok, %{id: id, contact: [], status: :valid}} ==
             Account.fetch("AcmeEx.AccountTest.abc123")
  end

  test "upsert" do
    id = AcmeEx.Nonce.next()
    assert %{id: id, contact: [], status: :valid} == Account.upsert("AcmeEx.AccountTest.abc124")
    assert %{id: id, contact: [], status: :valid} == Account.upsert("AcmeEx.AccountTest.abc124")
  end

  test "client_key" do
    assert "jwk123" == Account.client_key(%{protected: %{"jwk" => "jwk123"}})
  end
end

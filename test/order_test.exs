defmodule AcmeEx.OrderTest do
  use ExUnit.Case, async: false

  test "new" do
    account = AcmeEx.Account.new("abc124")
    id = AcmeEx.Nonce.next()

    expected = %{id: id, status: :pending, cert: nil, domains: ["d1", "d2"], token: "xxx123"}
    assert expected == AcmeEx.Order.new(account, ["d1", "d2"], "xxx123")
    assert {:ok, expected} == AcmeEx.Order.fetch("abc124", id)
  end

  test "new generate token" do
    account = AcmeEx.Account.new("abc126")
    id = AcmeEx.Nonce.next()

    actual = AcmeEx.Order.new(account, ["d1", "d2"])
    expected = %{id: id, status: :pending, cert: nil, domains: ["d1", "d2"], token: actual.token}

    assert expected == actual
    assert {:ok, expected} == AcmeEx.Order.fetch("abc126", id)
  end

  test "update" do
    account = AcmeEx.Account.new("abc125")
    id = AcmeEx.Nonce.next()

    _ = AcmeEx.Order.new(account, ["d1", "d2"], "xxx123")
    new_order = %{id: id, status: :pending, cert: nil, domains: ["d1", "d3"], token: "xxx124"}

    AcmeEx.Order.update("abc125", new_order)

    assert {:ok, new_order} == AcmeEx.Order.fetch("abc125", id)
  end
end

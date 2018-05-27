defmodule AcmeEx.OrderTest do
  use ExUnit.Case, async: false
  alias AcmeEx.{Account, Order, Nonce}

  test "new" do
    account = Account.new("abc124")
    id = Nonce.next()

    expected = %{id: id, status: :pending, cert: nil, domains: ["d1", "d2"], token: "xxx123"}
    assert expected == Order.new(["d1", "d2"], account, "xxx123")
    assert {:ok, expected} == Order.fetch("abc124", id)
  end

  test "new generate token" do
    account = Account.new("abc126")
    id = Nonce.next()

    actual = Order.new(["d1", "d2"], account)
    expected = %{id: id, status: :pending, cert: nil, domains: ["d1", "d2"], token: actual.token}

    assert expected == actual
    assert {:ok, expected} == Order.fetch("abc126", id)
  end

  test "update" do
    account = Account.new("abc125")
    id = Nonce.next()

    _ = Order.new(["d1", "d2"], account, "xxx123")
    new_order = %{id: id, status: :pending, cert: nil, domains: ["d1", "d3"], token: "xxx124"}

    Order.update("abc125", new_order)

    assert {:ok, new_order} == Order.fetch("abc125", id)
  end
end

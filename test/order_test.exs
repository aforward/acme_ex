defmodule AcmeEx.OrderTest do
  use ExUnit.Case, async: false
  alias AcmeEx.{Account, Order, Nonce}

  @config %{site: "http://localhost:9999"}

  test "new" do
    account = Account.new("abc124")
    order_id = Nonce.next()

    expected = %{
      id: order_id,
      status: :pending,
      cert: nil,
      domains: ["d1", "d2"],
      token: "xxx123"
    }

    assert expected == Order.new(["d1", "d2"], account, "xxx123")
    assert {:ok, expected} == Order.fetch("abc124", order_id)
    assert {:ok, expected} == Order.fetch(account.id, order_id)

    assert {expected, %{id: account.id}} == Order.decode_path("#{account.id}/#{order_id}")
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

    assert Order.update("abc125", new_order) == {:ok, new_order}

    assert {:ok, new_order} == Order.fetch("abc125", id)
  end

  test "domains" do
    assert ["foo.bar", "www.foo.bar", "blog.foo.bar"] ==
             AcmeEx.Order.domains(%{
               payload: %{
                 "identifiers" => [
                   %{"type" => "dns", "value" => "foo.bar"},
                   %{"type" => "dns", "value" => "www.foo.bar"},
                   %{"type" => "dns", "value" => "blog.foo.bar"}
                 ],
                 "resource" => "new-order",
                 "status" => "pending"
               }
             })
  end

  test "identifiers" do
    assert [%{type: "dns", value: "d1"}, %{type: "dns", value: "d2"}] ==
             Order.identifiers(%{domains: ["d1", "d2"]})
  end

  test "order_path" do
    assert "10/11" == Order.encode_path(%{id: 11}, %{id: 10})
  end

  test "authorization" do
    assert "http://localhost:9999/authorizations/10/11" ==
             Order.authorization(@config, %{id: 11}, %{id: 10})
  end

  test "location" do
    assert "http://localhost:9999/order/10/11" == Order.location(@config, %{id: 11}, %{id: 10})
  end

  test "finalize" do
    assert "http://localhost:9999/finalize/10/11" == Order.finalize(@config, %{id: 11}, %{id: 10})
  end

  test "expires" do
    assert "2018-09-20T11:11:13Z" == Order.expires(3601, ~N[2018-09-20 10:11:12])
    assert "2018-09-20T11:11:12Z" == Order.expires(nil, ~N[2018-09-20 10:11:12])
    assert !is_nil(Order.expires())
  end

  test "to_challenge" do
    assert %{
             type: "http-01",
             status: "pending",
             url: "http://localhost:9999/challenge/http/10/11",
             token: "def456"
           } ==
             Order.to_challenge(@config, %{id: 11, status: "pending", token: "def456"}, %{id: 10})
  end

  test "to_summary" do
    assert %{
             status: "pending",
             certificate: "http://localhost:9999/cert/10/11",
             identifier: %{type: "dns", value: "localhost"}
           } ==
             Order.to_summary(@config, %{id: 11, status: "pending", token: "def456"}, %{id: 10})
  end
end

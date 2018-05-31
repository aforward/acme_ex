defmodule AcmeEx.ChallengeTest do
  use ExUnit.Case, async: false

  alias AcmeEx.{Challenge, Account, Nonce, Order}

  @token "goodtoken"
  @thumbprint "goodthumb"
  @challenge "goodtoken.goodthumb"

  setup do
    AcmeEx.Apps.start()
    on_exit(fn -> AcmeEx.Apps.stop() end)
    :ok
  end

  def dns(), do: %{"mypony" => fn -> "localhost:4848" end}

  test "start_verify (ok)" do
    account = Account.new("AcmeEx.ChallengeTest.abc123")
    order_id = Nonce.next()
    order = Order.new(["mypony", "localhost:4849"], account, @token)

    Challenge.start_verify({order, account}, dns(), @thumbprint)
    Challenge.await_all()

    {:ok, updated} = Order.fetch("AcmeEx.ChallengeTest.abc123", order_id)

    assert %{
             id: order_id,
             domains: ["mypony", "localhost:4849"],
             cert: nil,
             status: :valid,
             token: @token
           } == updated
  end

  test "start_verify (fails)" do
    account = Account.new("AcmeEx.ChallengeTest.abc124")
    order_id = Nonce.next()
    order = Order.new(["mypony", "localhost:4849", "localhost:4850"], account, @token)

    Challenge.start_verify({order, account}, dns(), @thumbprint)
    Challenge.await_all()

    {:ok, updated} = Order.fetch("AcmeEx.ChallengeTest.abc124", order_id)

    assert %{
             id: order_id,
             domains: ["mypony", "localhost:4849", "localhost:4850"],
             cert: nil,
             status: :pending,
             token: @token
           } == updated
  end

  test "start_verify (errors)" do
    account = Account.new("AcmeEx.ChallengeTest.abc125")
    order_id = Nonce.next()
    order = Order.new(["localhost:4851"], account, @token)

    Challenge.start_verify({order, account}, dns(), @thumbprint)
    Challenge.await_all()

    {:ok, updated} = Order.fetch("AcmeEx.ChallengeTest.abc125", order_id)

    assert %{
             id: order_id,
             domains: ["localhost:4851"],
             cert: nil,
             status: :pending,
             token: @token
           } == updated
  end

  test "verify_domains" do
    assert true ==
             Challenge.verify_domains(
               ["mypony", "localhost:4849"],
               dns(),
               @token,
               @thumbprint
             )

    assert false ==
             Challenge.verify_domains(
               ["mypony", "localhost:4849", "localhost:4850"],
               dns(),
               @token,
               @thumbprint
             )

    assert false ==
             Challenge.verify_domains(
               ["mypony", "localhost:4849", "localhost:4850"],
               dns(),
               "badthumb",
               @thumbprint
             )
  end

  test "send (error)" do
    {:error, msg} = Challenge.request("localhost:9999", @token)

    assert msg ==
             {:failed_connect,
              [{:to_address, {'localhost', 9999}}, {:inet, [:inet], :econnrefused}]}
  end

  test "send (unknown)" do
    {:ok, {status, _, _}} = Challenge.request("localhost:4848", "unknowntoken")
    assert status == {'HTTP/1.1', 404, 'Not Found'}
  end

  test "send (ok)" do
    {:ok, reply} = Challenge.request("localhost:4848", @token)
    {{'HTTP/1.1', 200, 'OK'}, _, actual} = reply
    assert actual == @challenge
  end
end

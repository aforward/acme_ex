defmodule AcmeEx.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts AcmeEx.Router.init(site: "http://localhost:9999")

  defp http_call(route, method \\ :get) do
    method
    |> conn(route)
    |> AcmeEx.Router.call(@opts)
  end

  test "/ returns hello world" do
    conn = http_call("/")

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hello world"
  end

  test "/directory" do
    conn = http_call("/directory")

    assert conn.state == :sent
    assert conn.status == 200

    assert conn.resp_body |> Jason.decode!() == %{
             "keyChange" => "http://localhost:9999/key-change",
             "newAccount" => "http://localhost:9999/new-account",
             "newAuthz" => "http://localhost:9999/new-authz",
             "newNonce" => "http://localhost:9999/new-nonce",
             "newOrder" => "http://localhost:9999/new-order",
             "revokeCert" => "http://localhost:9999/revoke-cert"
           }
  end

  test "HEAD /new-x" do
    nonce = AcmeEx.Nonce.next()
    conn = http_call("/new-x", :head)

    assert conn.state == :sent
    assert conn.status == 405

    assert AcmeEx.Header.filter(conn, "replay-nonce") == [AcmeEx.Header.nonce(nonce)]

    assert conn.resp_body == ""
  end
end

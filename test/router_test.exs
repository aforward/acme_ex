defmodule AcmeEx.RouterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts AcmeEx.Router.init([])

  defp send(route) do
    :get
    |> conn(route)
    |> AcmeEx.Router.call(@opts)
  end

  test "/ returns hello world" do
    conn = send("/")

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "hello world"
  end
end

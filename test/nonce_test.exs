defmodule AcmeEx.NonceTest do
  use ExUnit.Case, async: true

  test "new" do
    first_nonce = AcmeEx.Nonce.new()
    nonce = AcmeEx.Nonce.new()
    assert nonce == first_nonce + 1
  end

  test "verify ok" do
    nonce = AcmeEx.Nonce.new()
    assert :ok == AcmeEx.Nonce.verify(nonce)
  end

  test "verify not ok" do
    assert :error == AcmeEx.Nonce.verify(-1)
  end

  test "encode" do
    assert "NQ" == AcmeEx.Nonce.encode(5)
  end
end

defmodule AcmeEx.HeaderTest do
  use ExUnit.Case, async: true

  test "nonce" do
    assert {"replay-nonce", AcmeEx.Nonce.encode(9)} == AcmeEx.Header.nonce(9)
  end
end

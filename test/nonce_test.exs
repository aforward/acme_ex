defmodule AcmeEx.NonceTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  test "new is unique" do
    first_nonce = AcmeEx.Nonce.new()
    nonce = AcmeEx.Nonce.new()
    assert nonce != first_nonce
  end

  test "nonce can be verified" do
    nonce = AcmeEx.Nonce.new()
    assert :ok == AcmeEx.Nonce.verify(nonce)
  end

  test "nonce can be verified only once" do
    nonce = AcmeEx.Nonce.new()
    assert :ok == AcmeEx.Nonce.verify(nonce)
    assert :error == AcmeEx.Nonce.verify(nonce)
  end

  test "unknown nonce isn't verified" do
    assert :error == AcmeEx.Nonce.verify(:unknown_nonce)
  end

  property "nonce is always unique" do
    check all nonces <- nonempty(list_of(nonce())) do
      assert Enum.uniq(nonces) == nonces
    end
  end

  property "nonce is always verifiable" do
    check all nonce <- nonce() do
      assert :ok == AcmeEx.Nonce.verify(nonce)
    end
  end

  property "nonce can only be verified once" do
    check all nonce <- nonce() do
      :ok = AcmeEx.Nonce.verify(nonce)
      assert :error == AcmeEx.Nonce.verify(nonce)
    end
  end

  defp nonce() do
    # we need to map a constant to ensure we get a different nonce every time
    unshrinkable(map(constant(:ignore), fn _ -> AcmeEx.Nonce.new() end))
  end
end

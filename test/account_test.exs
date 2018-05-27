defmodule AcmeEx.AccountTest do
  use ExUnit.Case, async: false

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

  test "thumbprint" do
    assert "iwCnbz72nRK1COrYZEgm2hvdPQ2oNnAwPxYd1Rk8CqU" ==
             Account.thumbprint(%{
               protected: %{
                 "jwk" => %{
                   "e" => "AQAB",
                   "kty" => "RSA",
                   "n" =>
                     "vKBBSJmA_zicdHvxUYClTB0FK8TUZBxOi_vmhFeoEgAizyApSYx7BoO6BJMLPVaC64dZv8gCIFpOFJhy7KAh_7Fl_is1c__C8QFy8_j4C0l81A5lsKVALByWcWSoh9BpsEISpmqgf-uRx2wwDo7CHQVp_jWJIxDdsmzbTtGImmNfsFMi0EHMvJyzC-INPKvinlsanGT4iCZzZwcsILib9SK6Iz6JJZUc4gTTnUXBEDgCUxwaepaUGx2xqmm0zxpxdKWA2oVaoCYSgyKrV3Hs9Ikl8KZnS9fI6ru7pnHtr83kAvhZnb8KOipbAPPu0adlPb8DmRDgdJ7ybokKf_I0xw"
                 }
               }
             })
  end
end

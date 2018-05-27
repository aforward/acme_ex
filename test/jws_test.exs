defmodule AcmeEx.JwsTest do
  use ExUnit.Case, async: true

  alias AcmeEx.Jws

  @body %{
          "payload" =>
            "ewogICJyZXNvdXJjZSI6ICJuZXctY2VydCIsCiAgImNzciI6ICJNSUlDaFRDQ0FXMENBUUl3QURDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGFQZ3JOeWdzSFRBc1EzN3YxbkttdWhBVW5xaV93UGdxcF85OTgyUld6dkYwendLcnUxRlBOaG9Sa2JHU25OakQxb1RvR0JsV2FFNWJEVWtaWjBHQW1WeGpIM1ZuNEIzczBOMDlkTzFyNXdZcktNakhaZlVLaU02bnN2cW9GalJpZWxod2wzT2hWMW5xYmJKRmM5ZFJxUTlQc0xhLWRVLTdqbWRCREg2NXF4bmgxaS1PNFY4LWxJMVRQdVJnOFdHWlo1eXE3TEZ6SEZzN3lKNzdXekRyWmxXS3UzVzIwekUwSW54RnVRbUhIMnNQT3U5clFNNzlpRXpPWHZqY2xSOWZ5OXRGaS1wZ0FMem5RRjE2WjlLRi1xdHpRZEtpa3NaTU9SWm9CS2J2MTE1c2NUbEhxdkN2MDg5d0xzTWVEc3hvRkFpR2dJVzJncTVJVVhPdHVLbWIwQ0F3RUFBYUJBTUQ0R0NTcUdTSWIzRFFFSkRqRXhNQzh3TFFZRFZSMFJCQ1l3SklJSFptOXZMbUpoY29JTGQzZDNMbVp2Ynk1aVlYS0NER0pzYjJjdVptOXZMbUpoY2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUxEUHBpRm9pbDRQYjVDeHh6RHRhYWZLTTdIRGtud1BfVVBJMkVVX1Z2dzJrQ3hXUGYwWUNLek15QlpPbElydmQ2SEtmUmk0QXRKLXdCbkJtQU9XR2dRM2JxZ0xKVEFQM1o5WHdwOERhR0NCc1VrQ3o3c2hzdHc2SUZlMHNsbVpTSXBQMjlub0U0Z3doNEpPeWdZV0tYX2hqdUp6RXhEa0VZRGR5a2psa2d6d0pSNlBZQmo4N05KTExDYlE1TE0yWHNPbTc0UzZMLWtXWTF0TV9wdkFBZjVmQ2FxcmF1QllPckhfUlZoMDM4bUhDY1dSalc3a2MtRkpnRzM2dlk5NUJseHJKZUdINVJDcWlHS2NIVElJSDRyVGJKak9pa2lmRDZLUkk0M25ZdzhQVE1HTWZSNnJiY0tGd0VQLWtkV2hVUEpEYURKTXpmX2pYOHoyLTNqYVJNUSIKfQ",
          "protected" =>
            "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTlEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9maW5hbGl6ZS8yLzMifQ",
          "signature" =>
            "iS3h3lMNe2LCflx2kcE9oD7OQinOPT1bD7Z1Oz8Gh8ZJNUmQaO16-fuyeX2OHeA3kQQQm6mGgDi_AAaBjXPjv8maGoPkTMJkUjY_mDeCN6X2pb5G1rlC4EGiQGLzhsiLx496gq4vVVJNPmc_wMdAEDM1sIZTJJfd7TqCkn8QSVe5FURZgoaJp7FpiFJY0RYqEnlAiJSPn9yTQrZIIbzZbfOBd3qV2v4fy3vRBeEYMYMbicNyTbVsrJ9HWpL0WlsR_FjEUqbe0E6ehFIz_fFBbNz49NKMJABr3t0jve2s_p2db6X-CTH_lx373rGPvFDVQYbZamWEkJpWPu4lxMhBZw"
        }
        |> Jason.encode!()

  @bad %{
    "payload" =>
      "ewogICJyZXNvdXJjZSI6ICJuZXctY2VydCIsCiAgImNzciI6ICJNSUlDaFRDQ0FXMENBUUl3QURDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGFQZ3JOeWdzSFRBc1EzN3YxbkttdWhBVW5xaV93UGdxcF85OTgyUld6dkYwendLcnUxRlBOaG9Sa2JHU25OakQxb1RvR0JsV2FFNWJEVWtaWjBHQW1WeGpIM1ZuNEIzczBOMDlkTzFyNXdZcktNakhaZlVLaU02bnN2cW9GalJpZWxod2wzT2hWMW5xYmJKRmM5ZFJxUTlQc0xhLWRVLTdqbWRCREg2NXF4bmgxaS1PNFY4LWxJMVRQdVJnOFdHWlo1eXE3TEZ6SEZzN3lKNzdXekRyWmxXS3UzVzIwekUwSW54RnVRbUhIMnNQT3U5clFNNzlpRXpPWHZqY2xSOWZ5OXRGaS1wZ0FMem5RRjE2WjlLRi1xdHpRZEtpa3NaTU9SWm9CS2J2MTE1c2NUbEhxdkN2MDg5d0xzTWVEc3hvRkFpR2dJVzJncTVJVVhPdHVLbWIwQ0F3RUFBYUJBTUQ0R0NTcUdTSWIzRFFFSkRqRXhNQzh3TFFZRFZSMFJCQ1l3SklJSFptOXZMbUpoY29JTGQzZDNMbVp2Ynk1aVlYS0NER0pzYjJjdVptOXZMbUpoY2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUxEUHBpRm9pbDRQYjVDeHh6RHRhYWZLTTdIRGtud1BfVVBJMkVVX1Z2dzJrQ3hXUGYwWUNLek15QlpPbElydmQ2SEtmUmk0QXRKLXdCbkJtQU9XR2dRM2JxZ0xKVEFQM1o5WHdwOERhR0NCc1VrQ3o3c2hzdHc2SUZlMHNsbVpTSXBQMjlub0U0Z3doNEpPeWdZV0tYX2hqdUp6RXhEa0VZRGR5a2psa2d6d0pSNlBZQmo4N05KTExDYlE1TE0yWHNPbTc0UzZMLWtXWTF0TV9wdkFBZjVmQ2FxcmF1QllPckhfUlZoMDM4bUhDY1dSalc3a2MtRkpnRzM2dlk5NUJseHJKZUdINVJDcWlHS2NIVElJSDRyVGJKak9pa2lmRDZLUkk0M25ZdzhQVE1HTWZSNnJiY0tGd0VQLWtkV2hVUEpEYURKTXpmX2pYOHoyLTNqYVJNUSIKfQ",
    "protected" =>
      "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTlEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9maW5hbGl6ZS8yLzMifQ",
    "signature" =>
      "xxx-fuyeX2OHeA3kQQQm6mGgDi_AAaBjXPjv8maGoPkTMJkUjY_mDeCN6X2pb5G1rlC4EGiQGLzhsiLx496gq4vVVJNPmc_wMdAEDM1sIZTJJfd7TqCkn8QSVe5FURZgoaJp7FpiFJY0RYqEnlAiJSPn9yTQrZIIbzZbfOBd3qV2v4fy3vRBeEYMYMbicNyTbVsrJ9HWpL0WlsR_FjEUqbe0E6ehFIz_fFBbNz49NKMJABr3t0jve2s_p2db6X-CTH_lx373rGPvFDVQYbZamWEkJpWPu4lxMhBZw"
  }

  test "format the raw input for JWS" do
    body = %{
      "payload" => "a",
      "protected" => "b",
      "signature" => "c"
    }

    expected = %{
      "payload" => "a",
      "signatures" => [
        %{
          "protected" => "b",
          "signature" => "c"
        }
      ]
    }

    assert Jws.format(body) == expected
    assert Jws.format(body |> Jason.encode!()) == expected
  end

  test "unwrap all fields the provided payload for review" do
    assert Jws.unwrap(@body) == %{
             "payload" => %{
               "csr" =>
                 "MIIChTCCAW0CAQIwADCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALaPgrNygsHTAsQ37v1nKmuhAUnqi_wPgqp_9982RWzvF0zwKru1FPNhoRkbGSnNjD1oToGBlWaE5bDUkZZ0GAmVxjH3Vn4B3s0N09dO1r5wYrKMjHZfUKiM6nsvqoFjRielhwl3OhV1nqbbJFc9dRqQ9PsLa-dU-7jmdBDH65qxnh1i-O4V8-lI1TPuRg8WGZZ5yq7LFzHFs7yJ77WzDrZlWKu3W20zE0InxFuQmHH2sPOu9rQM79iEzOXvjclR9fy9tFi-pgALznQF16Z9KF-qtzQdKiksZMORZoBKbv115scTlHqvCv089wLsMeDsxoFAiGgIW2gq5IUXOtuKmb0CAwEAAaBAMD4GCSqGSIb3DQEJDjExMC8wLQYDVR0RBCYwJIIHZm9vLmJhcoILd3d3LmZvby5iYXKCDGJsb2cuZm9vLmJhcjANBgkqhkiG9w0BAQsFAAOCAQEALDPpiFoil4Pb5CxxzDtaafKM7HDknwP_UPI2EU_Vvw2kCxWPf0YCKzMyBZOlIrvd6HKfRi4AtJ-wBnBmAOWGgQ3bqgLJTAP3Z9Xwp8DaGCBsUkCz7shstw6IFe0slmZSIpP29noE4gwh4JOygYWKX_hjuJzExDkEYDdykjlkgzwJR6PYBj87NJLLCbQ5LM2XsOm74S6L-kWY1tM_pvAAf5fCaqrauBYOrH_RVh038mHCcWRjW7kc-FJgG36vY95BlxrJeGH5RCqiGKcHTIIH4rTbJjOikifD6KRI43nYw8PTMGMfR6rbcKFwEP-kdWhUPJDaDJMzf_jX8z2-3jaRMQ",
               "resource" => "new-cert"
             },
             "protected" => %{
               "alg" => "RS256",
               "jwk" => %{
                 "e" => "AQAB",
                 "kty" => "RSA",
                 "n" =>
                   "vKBBSJmA_zicdHvxUYClTB0FK8TUZBxOi_vmhFeoEgAizyApSYx7BoO6BJMLPVaC64dZv8gCIFpOFJhy7KAh_7Fl_is1c__C8QFy8_j4C0l81A5lsKVALByWcWSoh9BpsEISpmqgf-uRx2wwDo7CHQVp_jWJIxDdsmzbTtGImmNfsFMi0EHMvJyzC-INPKvinlsanGT4iCZzZwcsILib9SK6Iz6JJZUc4gTTnUXBEDgCUxwaepaUGx2xqmm0zxpxdKWA2oVaoCYSgyKrV3Hs9Ikl8KZnS9fI6ru7pnHtr83kAvhZnb8KOipbAPPu0adlPb8DmRDgdJ7ybokKf_I0xw"
               },
               "nonce" => "NQ",
               "url" => "http://localhost:4002/finalize/2/3"
             },
             "signature" =>
               "iS3h3lMNe2LCflx2kcE9oD7OQinOPT1bD7Z1Oz8Gh8ZJNUmQaO16-fuyeX2OHeA3kQQQm6mGgDi_AAaBjXPjv8maGoPkTMJkUjY_mDeCN6X2pb5G1rlC4EGiQGLzhsiLx496gq4vVVJNPmc_wMdAEDM1sIZTJJfd7TqCkn8QSVe5FURZgoaJp7FpiFJY0RYqEnlAiJSPn9yTQrZIIbzZbfOBd3qV2v4fy3vRBeEYMYMbicNyTbVsrJ9HWpL0WlsR_FjEUqbe0E6ehFIz_fFBbNz49NKMJABr3t0jve2s_p2db6X-CTH_lx373rGPvFDVQYbZamWEkJpWPu4lxMhBZw"
           }
  end

  test "unwrap specific field" do
    assert Jws.unwrap(@body, "protected") == %{
             "alg" => "RS256",
             "jwk" => %{
               "e" => "AQAB",
               "kty" => "RSA",
               "n" =>
                 "vKBBSJmA_zicdHvxUYClTB0FK8TUZBxOi_vmhFeoEgAizyApSYx7BoO6BJMLPVaC64dZv8gCIFpOFJhy7KAh_7Fl_is1c__C8QFy8_j4C0l81A5lsKVALByWcWSoh9BpsEISpmqgf-uRx2wwDo7CHQVp_jWJIxDdsmzbTtGImmNfsFMi0EHMvJyzC-INPKvinlsanGT4iCZzZwcsILib9SK6Iz6JJZUc4gTTnUXBEDgCUxwaepaUGx2xqmm0zxpxdKWA2oVaoCYSgyKrV3Hs9Ikl8KZnS9fI6ru7pnHtr83kAvhZnb8KOipbAPPu0adlPb8DmRDgdJ7ybokKf_I0xw"
             },
             "nonce" => "NQ",
             "url" => "http://localhost:4002/finalize/2/3"
           }
  end

  test "key from JWS" do
    assert Jws.key(@body) == %JOSE.JWK{
             fields: %{},
             keys: :undefined,
             kty:
               {:jose_jwk_kty_rsa,
                {:RSAPublicKey,
                 23_811_826_026_329_008_338_100_056_241_082_191_517_489_912_306_135_195_292_143_345_295_030_092_436_154_961_623_017_046_505_658_558_934_478_574_653_300_130_036_877_089_866_732_747_215_162_483_607_213_646_902_175_585_252_965_807_431_923_272_480_205_226_737_020_355_153_733_761_974_191_797_493_858_281_570_916_306_968_174_016_415_848_727_241_476_147_946_508_505_502_295_586_185_484_689_897_562_498_050_495_515_177_809_599_921_299_802_388_952_498_239_548_483_749_443_408_588_713_703_995_682_958_427_243_115_309_256_218_404_952_142_482_464_139_004_534_099_965_967_840_154_442_663_324_816_212_158_433_816_046_221_353_883_147_568_606_320_146_283_732_743_203_725_805_233_725_582_860_845_017_583_728_569_513_356_458_727_112_669_390_598_223_177_217_910_770_528_731_871_498_481_561_468_823_058_058_816_744_385_587_133_258_581_292_231,
                 65537}}
           }
  end

  test "decode (good)" do
    assert Jws.decode(@body) ==
             {:ok,
              %{
                payload: %{
                  "csr" =>
                    "MIIChTCCAW0CAQIwADCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALaPgrNygsHTAsQ37v1nKmuhAUnqi_wPgqp_9982RWzvF0zwKru1FPNhoRkbGSnNjD1oToGBlWaE5bDUkZZ0GAmVxjH3Vn4B3s0N09dO1r5wYrKMjHZfUKiM6nsvqoFjRielhwl3OhV1nqbbJFc9dRqQ9PsLa-dU-7jmdBDH65qxnh1i-O4V8-lI1TPuRg8WGZZ5yq7LFzHFs7yJ77WzDrZlWKu3W20zE0InxFuQmHH2sPOu9rQM79iEzOXvjclR9fy9tFi-pgALznQF16Z9KF-qtzQdKiksZMORZoBKbv115scTlHqvCv089wLsMeDsxoFAiGgIW2gq5IUXOtuKmb0CAwEAAaBAMD4GCSqGSIb3DQEJDjExMC8wLQYDVR0RBCYwJIIHZm9vLmJhcoILd3d3LmZvby5iYXKCDGJsb2cuZm9vLmJhcjANBgkqhkiG9w0BAQsFAAOCAQEALDPpiFoil4Pb5CxxzDtaafKM7HDknwP_UPI2EU_Vvw2kCxWPf0YCKzMyBZOlIrvd6HKfRi4AtJ-wBnBmAOWGgQ3bqgLJTAP3Z9Xwp8DaGCBsUkCz7shstw6IFe0slmZSIpP29noE4gwh4JOygYWKX_hjuJzExDkEYDdykjlkgzwJR6PYBj87NJLLCbQ5LM2XsOm74S6L-kWY1tM_pvAAf5fCaqrauBYOrH_RVh038mHCcWRjW7kc-FJgG36vY95BlxrJeGH5RCqiGKcHTIIH4rTbJjOikifD6KRI43nYw8PTMGMfR6rbcKFwEP-kdWhUPJDaDJMzf_jX8z2-3jaRMQ",
                  "resource" => "new-cert"
                },
                protected: Jws.unwrap(@body, "protected")
              }}
  end

  test "decode (bad)" do
    assert Jws.decode(@bad) == {:error, "Unable to verify data due to {:badmatch, false}"}
  end

  test "thumbprint" do
    assert "iwCnbz72nRK1COrYZEgm2hvdPQ2oNnAwPxYd1Rk8CqU" ==
             Jws.thumbprint(%{
               "e" => "AQAB",
               "kty" => "RSA",
               "n" =>
                 "vKBBSJmA_zicdHvxUYClTB0FK8TUZBxOi_vmhFeoEgAizyApSYx7BoO6BJMLPVaC64dZv8gCIFpOFJhy7KAh_7Fl_is1c__C8QFy8_j4C0l81A5lsKVALByWcWSoh9BpsEISpmqgf-uRx2wwDo7CHQVp_jWJIxDdsmzbTtGImmNfsFMi0EHMvJyzC-INPKvinlsanGT4iCZzZwcsILib9SK6Iz6JJZUc4gTTnUXBEDgCUxwaepaUGx2xqmm0zxpxdKWA2oVaoCYSgyKrV3Hs9Ikl8KZnS9fI6ru7pnHtr83kAvhZnb8KOipbAPPu0adlPb8DmRDgdJ7ybokKf_I0xw"
             })
  end
end

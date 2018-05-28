defmodule AcmeEx.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias AcmeEx.{Router, Header, Nonce, Order, Db}

  @opts Router.init(site: "http://localhost:9999")

  @account_body %{
                  "payload" =>
                    "ewogICJyZXNvdXJjZSI6ICJuZXctY2VydCIsCiAgImNzciI6ICJNSUlDaFRDQ0FXMENBUUl3QURDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGFQZ3JOeWdzSFRBc1EzN3YxbkttdWhBVW5xaV93UGdxcF85OTgyUld6dkYwendLcnUxRlBOaG9Sa2JHU25OakQxb1RvR0JsV2FFNWJEVWtaWjBHQW1WeGpIM1ZuNEIzczBOMDlkTzFyNXdZcktNakhaZlVLaU02bnN2cW9GalJpZWxod2wzT2hWMW5xYmJKRmM5ZFJxUTlQc0xhLWRVLTdqbWRCREg2NXF4bmgxaS1PNFY4LWxJMVRQdVJnOFdHWlo1eXE3TEZ6SEZzN3lKNzdXekRyWmxXS3UzVzIwekUwSW54RnVRbUhIMnNQT3U5clFNNzlpRXpPWHZqY2xSOWZ5OXRGaS1wZ0FMem5RRjE2WjlLRi1xdHpRZEtpa3NaTU9SWm9CS2J2MTE1c2NUbEhxdkN2MDg5d0xzTWVEc3hvRkFpR2dJVzJncTVJVVhPdHVLbWIwQ0F3RUFBYUJBTUQ0R0NTcUdTSWIzRFFFSkRqRXhNQzh3TFFZRFZSMFJCQ1l3SklJSFptOXZMbUpoY29JTGQzZDNMbVp2Ynk1aVlYS0NER0pzYjJjdVptOXZMbUpoY2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUxEUHBpRm9pbDRQYjVDeHh6RHRhYWZLTTdIRGtud1BfVVBJMkVVX1Z2dzJrQ3hXUGYwWUNLek15QlpPbElydmQ2SEtmUmk0QXRKLXdCbkJtQU9XR2dRM2JxZ0xKVEFQM1o5WHdwOERhR0NCc1VrQ3o3c2hzdHc2SUZlMHNsbVpTSXBQMjlub0U0Z3doNEpPeWdZV0tYX2hqdUp6RXhEa0VZRGR5a2psa2d6d0pSNlBZQmo4N05KTExDYlE1TE0yWHNPbTc0UzZMLWtXWTF0TV9wdkFBZjVmQ2FxcmF1QllPckhfUlZoMDM4bUhDY1dSalc3a2MtRkpnRzM2dlk5NUJseHJKZUdINVJDcWlHS2NIVElJSDRyVGJKak9pa2lmRDZLUkk0M25ZdzhQVE1HTWZSNnJiY0tGd0VQLWtkV2hVUEpEYURKTXpmX2pYOHoyLTNqYVJNUSIKfQ",
                  "protected" =>
                    "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTlEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9maW5hbGl6ZS8yLzMifQ",
                  "signature" =>
                    "iS3h3lMNe2LCflx2kcE9oD7OQinOPT1bD7Z1Oz8Gh8ZJNUmQaO16-fuyeX2OHeA3kQQQm6mGgDi_AAaBjXPjv8maGoPkTMJkUjY_mDeCN6X2pb5G1rlC4EGiQGLzhsiLx496gq4vVVJNPmc_wMdAEDM1sIZTJJfd7TqCkn8QSVe5FURZgoaJp7FpiFJY0RYqEnlAiJSPn9yTQrZIIbzZbfOBd3qV2v4fy3vRBeEYMYMbicNyTbVsrJ9HWpL0WlsR_FjEUqbe0E6ehFIz_fFBbNz49NKMJABr3t0jve2s_p2db6X-CTH_lx373rGPvFDVQYbZamWEkJpWPu4lxMhBZw"
                }
                |> Jason.encode!()

  @new_order_body %{
                    "payload" =>
                      "ewogICJpZGVudGlmaWVycyI6IFsKICAgIHsKICAgICAgInR5cGUiOiAiZG5zIiwKICAgICAgInZhbHVlIjogImZvby5iYXIiCiAgICB9LAogICAgewogICAgICAidHlwZSI6ICJkbnMiLAogICAgICAidmFsdWUiOiAid3d3LmZvby5iYXIiCiAgICB9LAogICAgewogICAgICAidHlwZSI6ICJkbnMiLAogICAgICAidmFsdWUiOiAiYmxvZy5mb28uYmFyIgogICAgfQogIF0sCiAgInN0YXR1cyI6ICJwZW5kaW5nIiwKICAicmVzb3VyY2UiOiAibmV3LW9yZGVyIgp9",
                    "protected" =>
                      "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTVEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9uZXctb3JkZXIifQ",
                    "signature" =>
                      "e79DtE7I53iQ0COYUbFMYQcc7RyEDV0IpODiwyNYq3j1hHTWStDqPOzqJuUuwIqFn1HztTl78B1ckX1MraJmMIAG-b6Z6Zf2sIJf_bDjNdpDOz6FR_UqTivHB2dOc4EJQLb6EpR3z6NmLN95c-3dmTVnytVtUN9gvEIKJFXN40G7ZyGoJYclTaXjbGYRC0WLbZXoTSA7QP__rPKePh17U2xz_MKCUFRsAPSWaiZqqHLrVOq7gPVp_2RcpnCZ5KsPwiVZQSPQksyScJ_Wn90lnA89OdQFDesCjnxvFhwFvk2CC-nsYTZL02ciXHPGYd19zj-Lx-oYMrFVzb_1FQiGJg"
                  }
                  |> Jason.encode!()

  @finalize_order_body %{
                         "payload" =>
                           "ewogICJyZXNvdXJjZSI6ICJuZXctY2VydCIsCiAgImNzciI6ICJNSUlDaFRDQ0FXMENBUUl3QURDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGotRjNtcEhhbHM5aDZVSkRXbmZFRndJaVUzSlUyai1JXzZzS2UwVS02U3NfMHBhckl5M1ZoWGZuUll5QlhERnFobTk2UEV2SGQzMFBoY1dzeEVYU3UtaVlvbVI0Y05yd05RaU9sMjJXcWdVS0FuTWpMZDd0VGV1QTJDWVQ5b2x2d0FNZFNMd0xtcjVjak51dkVyMi01QjRoU01ZbkJBdzFMem5GdWVodkNUakJpa0hhRDhNb0JfbHlCd3Z1YWlQbDlNQ2lmUTJuaVlTcXZCTE1ZZmdfZXd0ekFIdHlWWWgyQzdJOTQ3Y01ORE1fNXItWGtCQ3kxRHlNaHk5UGxjcUJVYWZubkR0MkVyQjRjdEQ2dGFvbGEzcF9Vc1JwQVozaWpCa205VVZpcHBLTm44NlRPSHE0LXQ3Nnl2YjRhc1lESTJJd0NoRnZQajYyZ1YySHBScmMwQ0F3RUFBYUJBTUQ0R0NTcUdTSWIzRFFFSkRqRXhNQzh3TFFZRFZSMFJCQ1l3SklJSFptOXZMbUpoY29JTGQzZDNMbVp2Ynk1aVlYS0NER0pzYjJjdVptOXZMbUpoY2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQVo2TUkxU2xJNHhwcDVDZjZGREdtZy1MSE9lT2FqRTFwTTNqNTdfSmxzUl94Uk0ydm5WaDkxWUhJTzBVLUtmTGZxLUNJVk1FWmFNbDlrTll2STJCUUNNZnVzejBQU2UyRjNvTHZiVEt4Q0lJaFRZUS1qNnplVF9CajBBbklyRVdlQmt0V1BKclp6MWI3Wm8yeUMzTDh4aWVOX1ktNEJNbElBRHJGUUlXcEpyc0l3OHVhd183QzFTeEZGTE13T3BmQ3BPd3htYnBxdTJTS1pJUnhtRmQ3R1hjb3RpRmN4WWdwZHFtTGNjTHl2WDNweDRSWEJ5cXhtdFJuYjFEZy0ta1RXTExBZ2FMX24yblJyT3o5MmFfR0ppVnpRNFcwdHptdVhqZHA0SHhtWWxfSlIzVlpWWTE3R2ZUNXYxbDBIbXl0aWRMd1ZZb1YwWC02LUVoRVhESzFoQSIKfQ",
                         "protected" =>
                           "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTlEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9maW5hbGl6ZS8yLzMifQ",
                         "signature" =>
                           "ardSgv1qJqGW2vE0nDAQfjh8UVNHkp52y-HfXtMEwu3schZOKiXfom_cHU4BEfjWudphdWngU8CtFQwdz3C1jOsEugAbEjZLJwAluV72IQZ14cbtCopqiCLFMizlJTuwht-QjQMCdQSsdyV1R4K9lEVR3Uh4EKWxtpiwb7h3zumIca2a3WeO6JQq2BKch8p9lJ2G-L4TZch5tVIhoV2vVX2sUf8CTpvq8XcFbo7bQUWhVbReByFJI3ZIQSicnYfGc3sUvHhYMgDjGmmXjRxW7lBy1KYTb-Vo90Q_Fe9Kkrp6WWt3d_3yCyLyP82NwbvPDLanwsjjYq3bJ0DQfRUx_g"
                       }
                       |> Jason.encode!()

  setup _context do
    Db.reset()
    :ok
  end

  defp http_call(route, method \\ :get, body \\ "") do
    method
    |> conn(route, body)
    |> Router.call(@opts)
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
    nonce = Nonce.next()
    conn = http_call("/new-x", :head)

    assert conn.state == :sent
    assert conn.status == 405

    assert Header.filter(conn, "replay-nonce") == [Header.nonce(nonce)]

    assert conn.resp_body == ""
  end

  test "POST /new-account" do
    account_nonce = Nonce.next()
    reply_nonce = Nonce.follow(account_nonce)

    conn = http_call("/new-account", :post, @account_body)

    assert conn.state == :sent
    assert conn.status == 201

    assert Header.filter(conn, "replay-nonce") == [Header.nonce(reply_nonce)]

    assert conn.resp_body |> Jason.decode!() == %{
             "contact" => [],
             "id" => account_nonce,
             "status" => "valid"
           }
  end

  test "POST /new-order" do
    account_nonce = Nonce.next()
    order_nonce = Nonce.follow(account_nonce)
    reply_nonce = Nonce.follow(order_nonce)

    conn = http_call("/new-order", :post, @new_order_body)

    assert conn.state == :sent
    assert conn.status == 201

    assert Header.filter(conn, "replay-nonce") == [Header.nonce(reply_nonce)]

    actual = conn.resp_body |> Jason.decode!()

    assert actual |> Map.delete("expires") == %{
             "status" => "pending",
             "authorizations" => [
               "http://localhost:9999/authorizations/#{account_nonce}/#{order_nonce}"
             ],
             "finalize" => "http://localhost:9999/finalize/#{account_nonce}/#{order_nonce}",
             "identifiers" => [
               %{"type" => "dns", "value" => "foo.bar"},
               %{"type" => "dns", "value" => "www.foo.bar"},
               %{"type" => "dns", "value" => "blog.foo.bar"}
             ]
           }

    assert !is_nil(Map.get(actual, "expires"))
  end

  test "GET /authorizations/{account}/{order}" do
    account_nonce = Nonce.next()
    order_nonce = Nonce.follow(account_nonce)

    _conn = http_call("/new-order", :post, @new_order_body)
    conn = http_call("/authorizations/#{account_nonce}/#{order_nonce}", :get)

    {:ok, order} = Order.fetch(account_nonce, order_nonce)

    assert conn.state == :sent
    assert conn.status == 200

    assert conn.resp_body |> Jason.decode!() == %{
             "challenges" => [
               %{
                 "status" => "pending",
                 "token" => order.token,
                 "type" => "http-01",
                 "url" => "http://localhost:9999/challenge/http/#{account_nonce}/#{order_nonce}"
               }
             ],
             "identifier" => %{"type" => "dns", "value" => "localhost"},
             "status" => "pending"
           }
  end

  @tag :external
  test "POST /finalize/{account}/{order}" do
    account_nonce = Nonce.next()
    order_nonce = Nonce.follow(account_nonce)

    _conn = http_call("/new-order", :post, @new_order_body)
    {:ok, _} = Order.fetch(account_nonce, order_nonce)

    conn = http_call("/finalize/#{account_nonce}/#{order_nonce}", :post, @finalize_order_body)

    {:ok, order} = Order.fetch(account_nonce, order_nonce)
    assert !is_nil(order.cert)

    assert conn.state == :sent
    assert conn.status == 200

    assert conn.resp_body |> Jason.decode!() == %{
             "certificate" => "http://localhost:9999/cert/#{account_nonce}/#{order_nonce}",
             "identifier" => %{"type" => "dns", "value" => "localhost"},
             "status" => "pending"
           }
  end
end

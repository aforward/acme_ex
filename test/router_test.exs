defmodule AcmeEx.RouterTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias AcmeEx.{Router, Header, Nonce}

  @opts Router.init(site: "http://localhost:9999")
  @body %{
          "payload" =>
            "ewogICJyZXNvdXJjZSI6ICJuZXctY2VydCIsCiAgImNzciI6ICJNSUlDaFRDQ0FXMENBUUl3QURDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTGFQZ3JOeWdzSFRBc1EzN3YxbkttdWhBVW5xaV93UGdxcF85OTgyUld6dkYwendLcnUxRlBOaG9Sa2JHU25OakQxb1RvR0JsV2FFNWJEVWtaWjBHQW1WeGpIM1ZuNEIzczBOMDlkTzFyNXdZcktNakhaZlVLaU02bnN2cW9GalJpZWxod2wzT2hWMW5xYmJKRmM5ZFJxUTlQc0xhLWRVLTdqbWRCREg2NXF4bmgxaS1PNFY4LWxJMVRQdVJnOFdHWlo1eXE3TEZ6SEZzN3lKNzdXekRyWmxXS3UzVzIwekUwSW54RnVRbUhIMnNQT3U5clFNNzlpRXpPWHZqY2xSOWZ5OXRGaS1wZ0FMem5RRjE2WjlLRi1xdHpRZEtpa3NaTU9SWm9CS2J2MTE1c2NUbEhxdkN2MDg5d0xzTWVEc3hvRkFpR2dJVzJncTVJVVhPdHVLbWIwQ0F3RUFBYUJBTUQ0R0NTcUdTSWIzRFFFSkRqRXhNQzh3TFFZRFZSMFJCQ1l3SklJSFptOXZMbUpoY29JTGQzZDNMbVp2Ynk1aVlYS0NER0pzYjJjdVptOXZMbUpoY2pBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUxEUHBpRm9pbDRQYjVDeHh6RHRhYWZLTTdIRGtud1BfVVBJMkVVX1Z2dzJrQ3hXUGYwWUNLek15QlpPbElydmQ2SEtmUmk0QXRKLXdCbkJtQU9XR2dRM2JxZ0xKVEFQM1o5WHdwOERhR0NCc1VrQ3o3c2hzdHc2SUZlMHNsbVpTSXBQMjlub0U0Z3doNEpPeWdZV0tYX2hqdUp6RXhEa0VZRGR5a2psa2d6d0pSNlBZQmo4N05KTExDYlE1TE0yWHNPbTc0UzZMLWtXWTF0TV9wdkFBZjVmQ2FxcmF1QllPckhfUlZoMDM4bUhDY1dSalc3a2MtRkpnRzM2dlk5NUJseHJKZUdINVJDcWlHS2NIVElJSDRyVGJKak9pa2lmRDZLUkk0M25ZdzhQVE1HTWZSNnJiY0tGd0VQLWtkV2hVUEpEYURKTXpmX2pYOHoyLTNqYVJNUSIKfQ",
          "protected" =>
            "eyJhbGciOiAiUlMyNTYiLCAiandrIjogeyJuIjogInZLQkJTSm1BX3ppY2RIdnhVWUNsVEIwRks4VFVaQnhPaV92bWhGZW9FZ0FpenlBcFNZeDdCb082QkpNTFBWYUM2NGRadjhnQ0lGcE9GSmh5N0tBaF83RmxfaXMxY19fQzhRRnk4X2o0QzBsODFBNWxzS1ZBTEJ5V2NXU29oOUJwc0VJU3BtcWdmLXVSeDJ3d0RvN0NIUVZwX2pXSkl4RGRzbXpiVHRHSW1tTmZzRk1pMEVITXZKeXpDLUlOUEt2aW5sc2FuR1Q0aUNaelp3Y3NJTGliOVNLNkl6NkpKWlVjNGdUVG5VWEJFRGdDVXh3YWVwYVVHeDJ4cW1tMHp4cHhkS1dBMm9WYW9DWVNneUtyVjNIczlJa2w4S1puUzlmSTZydTdwbkh0cjgza0F2aFpuYjhLT2lwYkFQUHUwYWRsUGI4RG1SRGdkSjd5Ym9rS2ZfSTB4dyIsICJlIjogIkFRQUIiLCAia3R5IjogIlJTQSJ9LCAibm9uY2UiOiAiTlEiLCAidXJsIjogImh0dHA6Ly9sb2NhbGhvc3Q6NDAwMi9maW5hbGl6ZS8yLzMifQ",
          "signature" =>
            "iS3h3lMNe2LCflx2kcE9oD7OQinOPT1bD7Z1Oz8Gh8ZJNUmQaO16-fuyeX2OHeA3kQQQm6mGgDi_AAaBjXPjv8maGoPkTMJkUjY_mDeCN6X2pb5G1rlC4EGiQGLzhsiLx496gq4vVVJNPmc_wMdAEDM1sIZTJJfd7TqCkn8QSVe5FURZgoaJp7FpiFJY0RYqEnlAiJSPn9yTQrZIIbzZbfOBd3qV2v4fy3vRBeEYMYMbicNyTbVsrJ9HWpL0WlsR_FjEUqbe0E6ehFIz_fFBbNz49NKMJABr3t0jve2s_p2db6X-CTH_lx373rGPvFDVQYbZamWEkJpWPu4lxMhBZw"
        }
        |> Jason.encode!()

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

    conn = http_call("/new-account", :post, @body)

    assert conn.state == :sent
    assert conn.status == 201

    assert Header.filter(conn, "replay-nonce") == [Header.nonce(reply_nonce)]

    assert conn.resp_body |> Jason.decode!() == %{
             "contact" => [],
             "id" => account_nonce,
             "status" => "valid"
           }
  end
end

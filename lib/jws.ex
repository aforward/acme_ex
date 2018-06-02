defmodule AcmeEx.Jws do
  def client_key(request), do: Map.fetch!(request.protected, "jwk")

  def decode(""), do: {:error, :empty}

  def decode(body) when is_binary(body) do
    body |> decode_json!() |> decode()
  end

  def decode(data) do
    case verify(data) do
      {:ok, payload} ->
        {:ok, %{payload: payload, protected: data |> unwrap("protected")}}

      error ->
        error
    end
  end

  def thumbprint(request), do: JOSE.JWK.thumbprint(request)

  def unwrap(body) do
    body
    |> decode_json!()
    |> Enum.map(fn {k, v} ->
      case k do
        "signature" -> {k, v}
        _ -> {k, v |> decode64_json!()}
      end
    end)
    |> Map.new()
  end

  def unwrap(body, field), do: body |> unwrap() |> Map.get(field)

  def format(body) do
    body
    |> decode_json!()
    |> (&%{
          "payload" => Map.fetch!(&1, "payload"),
          "signatures" => [
            %{
              "protected" => Map.fetch!(&1, "protected"),
              "signature" => Map.fetch!(&1, "signature")
            }
          ]
        }).()
  end

  def key(body) do
    body
    |> unwrap()
    |> (&get_in(&1, ["protected", "jwk"])).()
    |> JOSE.JWK.from()
  end

  defp verify(body) do
    body
    |> decode_json!()
    |> (&(case JOSE.JWS.verify([key(&1)], format(&1)) do
            [{_jwk, [{true, payload, _jws}]}] ->
              {:ok, payload |> decode_json!}

            {:error, reason} ->
              {:error, "Unable to verify data due to #{reason |> Kernel.inspect()}"}
          end)).()
  end

  defp decode_json!(body) when is_binary(body), do: Jason.decode!(body)
  defp decode_json!(data), do: data

  defp decode64_json!(v) do
    v
    |> Base.decode64!(padding: false)
    |> Jason.decode!()
  end
end

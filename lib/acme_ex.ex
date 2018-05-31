defmodule AcmeEx do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  @moduledoc """

  Start a local Acme authentication server.

  By default, it will start listening on `http://localhost:4002`.
  But you can override both the `site` and the `port` if you wish.

  For example,

      Acme.start(:permanent, [port: 4003, site: "http://mylocal:4003"])

  """

  def start(_type, args) do
    import Supervisor.Spec, warn: false

    JOSE.json_module(AcmeEx.Jason)

    Supervisor.start_link(
      [
        {Plug.Adapters.Cowboy2,
         scheme: :http, plug: {AcmeEx.Router, [site: site(args)]}, options: [port: port(args)]},
        AcmeEx.Db,
        {Task.Supervisor, name: AcmeEx.ChallengeSupervisor, restart: :transient, max_restarts: 2}
      ],
      strategy: :one_for_one,
      name: AcmeEx.Component
    )
  end

  @doc """
  Determine the Acme `port` to run on.  This will default to 4002 if none provided.

  ## Examples

      iex> AcmeEx.port([])
      4002

      iex> AcmeEx.port([port: 4848])
      4848

  """
  def port(args), do: args[:port] || 4002

  @doc """
  Determine the Acme `site` URL.  You can provide this directly
  when you start the app using

  ## Examples

      iex> AcmeEx.site([])
      "http://localhost:4002"

      iex> AcmeEx.site([port: 4848])
      "http://localhost:4848"

      iex> AcmeEx.site([site: "http://localhost:9999"])
      "http://localhost:9999"

  """
  def site(args), do: args[:site] || "http://localhost:#{port(args)}"

  @doc false
  def dir(), do: Application.app_dir(:acme_ex)
end

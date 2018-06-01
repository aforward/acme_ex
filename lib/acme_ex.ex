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
        AcmeEx.Router.child_spec(args),
        AcmeEx.Db,
        {Task.Supervisor, name: AcmeEx.ChallengeSupervisor, restart: :transient, max_restarts: 2}
      ],
      strategy: :one_for_one,
      name: AcmeEx.Component
    )
  end

  @doc false
  def dir(), do: Application.app_dir(:acme_ex)
end

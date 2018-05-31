defmodule AcmeEx do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    JOSE.json_module(AcmeEx.Jason)

    Supervisor.start_link(
      [
        {Plug.Adapters.Cowboy2,
         scheme: :http,
         plug: {AcmeEx.Router, [site: "http://localhost:4002"]},
         options: [port: 4002]},
        AcmeEx.Db,
        {Task.Supervisor, name: AcmeEx.ChallengeSupervisor, restart: :transient, max_restarts: 2}
      ],
      strategy: :one_for_one,
      name: AcmeEx.Component
    )
  end

  def dir(), do: Application.app_dir(:acme_ex)
end

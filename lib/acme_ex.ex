defmodule AcmeEx do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {Plug.Adapters.Cowboy2, scheme: :http, plug: AcmeEx.Router, options: [port: 4001]}
    ]

    opts = [
      strategy: :one_for_one,
      name: AcmeEx.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
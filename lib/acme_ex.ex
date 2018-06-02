defmodule AcmeEx do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application

  @moduledoc """

  By default, the application does nothing.  You must start the
  server's directly by adding

      AcmeEx.Standalone.child_spec(opts)

  Or, you can add the children specs directly to your supervisor

      AcmeEx.Standalone.children_specs(opts)

  Or, by running the server task

      mix acme.server

  """

  @doc false
  def start(_type, _opts) do
    import Supervisor.Spec, warn: false
    JOSE.json_module(AcmeEx.Jason)

    Supervisor.start_link(
      AcmeEx.Standalone.children_specs(),
      strategy: :one_for_one,
      name: AcmeEx.Component
    )
  end

  @doc false
  def dir(), do: Application.app_dir(:acme_ex)

  @doc false
  def version(), do: unquote(Mix.Project.config()[:version])
end

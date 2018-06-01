defmodule AcmeEx do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  use Application
  alias DynamicSupervisor, as: DynS

  @moduledoc """

  Start a local Acme authentication server.

  By default, it will start listening on `http://localhost:4002`.
  But you can override both the `site` and the `port` if you wish.

  For example,

      Acme.start(:permanent, [port: 4003, site: "http://mylocal:4003"])

  """

  @doc """
  This will start the application, but nothing much happens except
  for a do-nothing AcmeEx.Server.  Only if you really want the
  Acme server to run would you then start it with

      AcmeEx.server(opts)

  Where the opts provide run-time configuration such as `:port`, `:site`
  and `:adapter`.
  """
  def start(_type, opts) do
    import Supervisor.Spec, warn: false

    JOSE.json_module(AcmeEx.Jason)

    started =
      Supervisor.start_link(
        [
          {DynS, name: AcmeEx.Server, strategy: :one_for_one}
        ],
        strategy: :one_for_one,
        name: AcmeEx.Component
      )

    if opts[:serve_endpoints], do: server(opts)
    started
  end

  @doc """
  Actually start the server
  """
  def server(opts \\ []) do
    {:ok, db} = DynS.start_child(AcmeEx.Server, AcmeEx.Db)
    {:ok, router} = DynS.start_child(AcmeEx.Server, AcmeEx.Router.child_spec(opts))
    {:ok, challenge} = DynS.start_child(AcmeEx.Server, AcmeEx.Challenge.child_spec(opts))
    {:ok, db: db, router: router, challenge: challenge}
  end

  @doc false
  def dir(), do: Application.app_dir(:acme_ex)

  @doc false
  def version(), do: unquote(Mix.Project.config()[:version])
end

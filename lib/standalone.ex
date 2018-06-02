defmodule AcmeEx.Standalone do
  def child_spec(opts) do
    %{id: __MODULE__, type: :supervisor, start: {__MODULE__, :start_link, [opts]}}
  end

  def children_specs() do
    if Application.get_env(:acme_ex, :serve_endpoints) do
      IO.puts("Starting standalone ACME server.")

      Application.get_env(:acme_ex, :opts)
      |> children_specs()
    else
      []
    end
  end

  def children_specs(opts) do
    [
      AcmeEx.Db,
      AcmeEx.Router.child_spec(opts),
      AcmeEx.Challenge.child_spec(opts)
    ]
  end

  def start_link(opts \\ []) do
    Supervisor.start_link(
      children_specs(opts),
      name: AcmeEx.StandaloneSupervisor,
      strategy: :one_for_one
    )
  end
end

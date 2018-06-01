defmodule Mix.Tasks.Acme.Server do
  use Mix.Task

  @shortdoc "Starts ACME server"

  @moduledoc """
  Starts the ACME server listening on the appropriate port / site.

  ## Command line options

  The following additional flags are available:

  * `--adapter`   - Accepts `Cowboy` or `Cowboy2` (but defaults just fine!)
  * `--port`      - Defaults to `4002`
  * `--site`      - Defaults to `http://localhost:{port}`

  """

  @doc false
  def run(args) do
    Application.ensure_all_started(:acme_ex)

    args
    |> OptionParser.parse(strict: [site: :string, port: :integer, adapter: :string])
    |> (fn {opts, _, _} -> opts end).()
    |> AcmeEx.server()

    Mix.Tasks.Run.run(run_args())
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end

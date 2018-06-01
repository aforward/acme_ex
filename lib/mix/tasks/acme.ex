defmodule Mix.Tasks.Acme do
  use Mix.Task

  @shortdoc "ProvidStarts ACME server"

  @moduledoc """
  Get help about how to use the ACME server

  """

  @doc false
  def run(_) do
    Mix.shell().info("acme v" <> AcmeEx.version())
    Mix.shell().info("Run a local ACME SSL server to generate SSL certificates for your site")
    Mix.shell().info("")

    Mix.shell().info("Available tasks:")

    # Run `mix help --search acme.`, and
    # and paste here
    Mix.shell().info("    mix acme.server # Starts ACME server")

    Mix.shell().info("")
    Mix.shell().info("")
    Mix.shell().info("Further information can be found here:")
    Mix.shell().info("  -- https://hex.pm/packages/acme_ex")
    Mix.shell().info("  -- https://github.com/aforward/acme_ex")
    Mix.shell().info("")
  end
end

defmodule AcmeEx.Mixfile do
  use Mix.Project

  @name :acme_ex
  @version "0.1.0"

  @deps [
    {:jason, "~> 1.0"},
    {:jose, "~> 1.8"},
    {:cowboy, "~> 2.0"},
    {:plug, "~> 1.0"}
    # { :earmark, ">0.1.5" },
    # { :ex_doc,  "1.2.3", only: [ :dev, :test ] },
    # { :my_app:  path: "../my_app" },
  ]

  @aliases []

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: elixirc_paths(:prod) ++ ["test/support"]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @name,
      version: @version,
      elixir: ">= 1.6.0",
      deps: @deps,
      aliases: @aliases,
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: in_production
    ]
  end

  def application do
    [
      mod: {AcmeEx, []},
      extra_applications: [
        :logger,
        :cowboy,
        :plug
      ]
    ]
  end
end

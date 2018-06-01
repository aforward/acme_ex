defmodule AcmeEx.Mixfile do
  use Mix.Project

  @app :acme_ex
  @version "0.1.1"
  @git_url "https://github.com/aforward/acme_ex"
  @home_url @git_url

  @deps [
    {:jason, "~> 1.0"},
    {:jose, "~> 1.8"},
    {:cowboy, "~> 2.0"},
    {:plug, "~> 1.0"},
    {:version_tasks, "~> 0.10"},
    {:ex_doc, "> 0.0.0", only: [:dev, :test]}
  ]

  @docs [
    main: "AcmeEx",
    extras: ["README.md"]
  ]

  @aliases []

  @package [
    name: @app,
    files: ["lib", "mix.exs", "README*", "LICENSE*", "assets"],
    maintainers: ["Andrew Forward"],
    licenses: ["MIT"],
    links: %{"GitHub" => @git_url}
  ]

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: elixirc_paths(:prod) ++ ["test/support"]

  # ------------------------------------------------------------

  def project do
    in_production = Mix.env() == :prod

    [
      app: @app,
      version: @version,
      elixir: ">= 1.6.0",
      name: @app,
      description: "A test Acme server for generating SSL Certificates",
      package: @package,
      source_url: @git_url,
      homepage_url: @home_url,
      docs: @docs,
      build_embedded: in_production,
      start_permanent: in_production,
      deps: @deps,
      aliases: @aliases,
      elixirc_paths: elixirc_paths(Mix.env())
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

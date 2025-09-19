defmodule Exins.MixProject do
  use Mix.Project

  def project do
    [
      app: :exins,
      version: "0.20.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Exins.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash, "~> 3.5"},
      {:ash_money, "~> 0.2"},
      {:ash_phoenix, "~> 2.3"},
      {:ash_postgres, "~> 2.6"},
      {:bandit, "~> 1.8"},
      {:dns_cluster, "~> 0.1"},
      {:ecto_sql, "~> 3.13"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:ex_money_sql, "~> 1.11"},
      {:finch, "~> 0.20"},
      {:floki, ">= 0.38.0", only: :test},
      {:gettext, "~> 0.26"},
      {:heroicons,
      github: "tailwindlabs/heroicons",
      tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:jason, "~> 1.4"},
      {:phoenix, "~> 1.8"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.2"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0", override: true},
      {:picosat_elixir, "~> 0.2"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.19"},
      {:tailwind, "~> 0.4", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.1"},
      {:telemetry_poller, "~> 1.3"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind exins", "esbuild exins"],
      "assets.deploy": [
        "tailwind exins --minify",
        "esbuild exins --minify",
        "phx.digest"
      ]
    ]
  end

  def min_pg_version do
    %Version{major: 17, minor: 6, patch: 0}
  end
end

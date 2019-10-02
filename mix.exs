defmodule Nebula.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nebula,
      version: "0.0.2",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [plt_add_deps: :transitive],
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Nebula.Application, []},
      applications: [
        :phoenix,
        :phoenix_pubsub,
        :poison,
        :cowboy,
        :logger,
        :gettext,
        :comeonin,
        :cdmioid,
        :memcache_client,
        :nebula_metadata
      ]
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
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:linguist, "~> 0.1"},
      {:pooler, "~> 1.5"},
      {:phoenix, "~> 1.4"},
      {:poison, "~> 4.0", override: true},
      {:phoenix_pubsub, "~> 1.1"},
      {:gettext, "~> 0.17"},
      {:cowboy, "~> 2.6"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.8"},
      {:logger_file_backend, "~> 0.0"},
      {:comeonin, "~> 5.0"},
      {:uuid, "~> 1.1"},
      {:hexate, "~> 0.6"},
      {:memcache_client, "~> 1.1"},
      {:telemetry, "~> 0.4"},
      {:cdmioid, git: "https://github.com/building39/cdmioid.git", tag: "0.1.1"},
      {:nebula_metadata, git: "git@github.com:building39/nebula_metadata.git", tag: "v0.3.1"}
    ]
  end
end

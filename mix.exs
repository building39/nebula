defmodule Nebula.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nebula,
      version: "0.0.2",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:linguist, "~> 0.1"},
      {:pooler, "~> 1.5"},
      {:phoenix, "~> 1.3"},
      {:poison, ">= 3.1.0", override: true},
      {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.13"},
      {:cowboy, "~> 1.0"},
      {:logger_file_backend, "~> 0.0"},
      {:comeonin, "~> 4.0"},
      {:uuid, "~> 1.1"},
      {:hexate, ">= 0.6.0"},
      {:memcache_client, "~> 1.1.0"},
      {:cdmioid, git: "https://github.com/building39/cdmioid.git", tag: "0.1.1"},
      {:nebula_metadata, git: "git@github.com:building39/nebula_metadata.git", tag: "develop"}
    ]
  end
end

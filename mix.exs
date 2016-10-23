defmodule Nebula.Mixfile do
  use Mix.Project

  def project do
    [app: :nebula,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Nebula, []},
     applications: [:phoenix,
                    :phoenix_pubsub,
                    :cowboy,
                    :logger,
                    :gettext,
                    :comeonin,
                    :cdmioid,
                    :nebula_metadata]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:logger_file_backend, "~> 0.0"},
     {:comeonin, "~> 2.0"},
     {:uuid, "~> 1.1" },
     {:hexate,  ">= 0.6.0"},
     {:cdmioid, git: "https://github.com/building39/cdmioid.git", tag: "0.1.1"},
     {:nebula_metadata, git: "git@github.com:building39/nebula_metadata.git", tag: "0.1.8"}
   ]
  end
end

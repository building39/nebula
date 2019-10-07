# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :nebula, NebulaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VCK6/hzwTbL5DeSDYLLoPgPOyGEmutHYkr7nl4zDBrGVsTvebsMbOJO6Rl59UD0u",
  render_errors: [view: NebulaWeb.ErrorView, accepts: ~w(json cdmia cdmic cdmid cdmio cdmiq)],
  pubsub: [name: NebulaWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure mime types
config :mime, :types, %{
  "application/cdmi-capability" => ["cdmia"],
  "application/cdmi-container" => ["cdmic"],
  "application/cdmi-domain" => ["cdmid"],
  "application/cdmi-object" => ["cdmio"],
  "application/cdmi-queue" => ["cdmiq"]
}

config :memcache_client,
  transcoder: Memcache.Client.Transcoder.Erlang

# config :phoenix, :json_encoding, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

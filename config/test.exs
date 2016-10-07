use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nebula, Nebula.Endpoint,
  http: [port: 4001],
  server: false,
  cdmi_version: "1.1",

# Print only warnings and errors during test
config :logger, level: :warn

use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :nebula, NebulaWeb.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :nebula,
  cdmi_version: ["1.1", "1.1.1"]

  config :logger,
    format: "[$level] $message\n",
    metadata: [:file, :line],
    backends: [{LoggerFileBackend, :info},
               {LoggerFileBackend, :debug},
               {LoggerFileBackend, :error}]

  config :logger, :debug,
    colors: [enabled: :true],
    metadata: [:pid, :file, :line],
    path: "/var/log/nebula/debug.log",
    format: "$time $date [$level] $levelpad $metadata $message\n",
    level: :debug

  config :logger, :error,
    colors: [enabled: :true],
    metadata: [:pid],
    path: "/var/log/nebula/error.log",
    format: "$time $date [$level] $levelpad $metadata $message\n",
    level: :error

  config :logger, :info,
    colors: [enabled: :true],
    metadata: [:pid],
    path: "/var/log/nebula/info.log",
    format: "$time $date [$level] $levelpad $metadata $message\n",
    level: :info

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
#config :phoenix, :json_library, Jason

config :pooler, pools:
  [
    [
      name: :riaklocal1,
      group: :riak,
      max_count: 10,
      init_count: 5,
      start_mfa: { Riak.Connection, :start_link, ['nebriak1.fuzzcat.loc', 8087] }
    ]
  ]

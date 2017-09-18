# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :ontag_core,
  ecto_repos: [OntagCore.Repo]

# Configures the endpoint
config :ontag_core, OntagCoreWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NunFvfbCbiAZXz02QJFHOSG4/axT7J3tKVhYpVewpk0wznR7n4MmQxPK8Wg9ZK8v",
  render_errors: [view: OntagCoreWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OntagCore.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Guardian. Override secret_key with a valid hidden value
config :ontag_core, OntagCore.Guardian,
  issuer: "liqen_core",
  secret_key: "VQ1QVNnBfpMcU4X97BeJ4v0zc24G+AoANoMiCGlT41YTUUSlC7jPG2E5Z1NTj9OH"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

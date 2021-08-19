# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :autojoin_example,
  ecto_repos: [AutojoinExample.Repo]

# Configures the endpoint
config :autojoin_example, AutojoinExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tEYmVdHv4j3I+KsCTAqRP/tXZ1Ln7Yz8rhIsG5Qk/YSyDnHvframclWzGNegqx/M",
  render_errors: [view: AutojoinExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: AutojoinExample.PubSub,
  live_view: [signing_salt: "APexiKiq"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

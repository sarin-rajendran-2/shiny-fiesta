import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :exins, Exins.Repo,
  username: "postgres",
  password: "postgres",
  database: "exins_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "db",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :exins_web, ExinsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "WUwpXLxCwvFHog1Wb7pW7vrMwrUlmbshCu6xwvPQJVwb3xYZ94d0geokZpY6sKB3",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :exins, Exins.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

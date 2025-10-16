defmodule Exins.Application do
  @moduledoc """
  The Exins application is the main entry point for the OTP application.

  It is responsible for starting the supervision tree, which includes
  the endpoint, the database repository, and the pubsub system.
  """

  use Application

  @doc """
  Starts the Exins application.

  This function is called when the application is started and is responsible
  for creating the supervision tree.

  ## Parameters
    - `_type`: The type of start.
    - `_args`: A list of arguments.

  ## Returns
    - `{:ok, pid}` on success, where `pid` is the process identifier of the supervisor.
    - `{:error, reason}` on failure.
  """
  @impl true
  def start(_type, _args) do
    children = [
      ExinsWeb.Telemetry,
      Exins.Repo,
      {DNSCluster, query: Application.get_env(:exins, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Exins.PubSub},
      # Start a worker by calling: Exins.Worker.start_link(arg)
      # {Exins.Worker, arg},
      # Start to serve requests, typically the last entry
      ExinsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exins.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Handles application configuration changes.

  This function is called by Phoenix whenever the application's configuration
  is updated.

  ## Parameters
    - `changed`: A keyword list of changed configuration.
    - `_new`: A keyword list of new configuration.
    - `removed`: A list of removed configuration keys.

  ## Returns
    - `:ok`
  """
  @impl true
  def config_change(changed, _new, removed) do
    ExinsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule Exins.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Exins.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Exins.PubSub}
      # Start a worker by calling: Exins.Worker.start_link(arg)
      # {Exins.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Exins.Supervisor)
  end
end

defmodule LiveviewCursors.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveviewCursorsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveviewCursors.PubSub},
      # Start the Endpoint (http/https)
      LiveviewCursorsWeb.Endpoint,
      # Start a worker by calling: LiveviewCursors.Worker.start_link(arg)
      # {LiveviewCursors.Worker, arg}
      LiveviewCursorsWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveviewCursors.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveviewCursorsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

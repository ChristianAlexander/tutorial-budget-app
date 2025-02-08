defmodule Budgie.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BudgieWeb.Telemetry,
      Budgie.Repo,
      {DNSCluster, query: Application.get_env(:budgie, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Budgie.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Budgie.Finch},
      # Start a worker by calling: Budgie.Worker.start_link(arg)
      # {Budgie.Worker, arg},
      # Start to serve requests, typically the last entry
      BudgieWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Budgie.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BudgieWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

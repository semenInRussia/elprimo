defmodule Elprimo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # run all databases-like things
    children = [
      # a repository for Postgres Database
      Elprimo.Repo,
      # an agent to check the user state
      Elprimo.State,
      # a telegram
      Elprimo.UpdatesPoller
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

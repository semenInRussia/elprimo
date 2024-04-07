defmodule Elprimo.Application do
  @moduledoc """
  The entry point of program which run all needed processes, including
  the following ones:

  - `Ecto`
     PostgreSQL ORM
  - `Elprimo.State`
     In-memory storage of the current user state
  - `Elprimo.UpdatesPoller`
     A thing that handle income updates
  """

  use Application

  @impl true
  def start(_type, _args) do
    # run all databases-like things
    children = [
      # a repository for PostgreSQL Database
      Elprimo.Repo,
      # agent to determine the user state
      Elprimo.State,
      # telegram handler of events
      Elprimo.UpdatesPoller
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

defmodule Elprimo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Elprimo.Repo
    ]

    opts = [strategy: :one_for_one, name: Elprimo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

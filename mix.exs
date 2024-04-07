defmodule Elprimo.MixProject do
  use Mix.Project

  def project do
    [
      app: :elprimo,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Elprimo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # UUID
      {:uuid, "~> 1.1.8"},

      # database library (Ecto) deps:
      {:ecto_sql, "~> 3.2"},
      {:postgrex, "~> 0.15"},

      # telegram library (Telegex) deps
      {:telegex, "~> 1.4.0"},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:finch, "~> 0.16.0"},
      {:multipart, "~> 0.4.0"},
      {:plug, "~> 1.14"},
      {:plug_cowboy, "~> 2.6"},
      {:bandit, "~> 1.1"},
      {:remote_ip, "~> 1.1"}
    ]
  end
end

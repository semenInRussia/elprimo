import Config

config :elprimo, Elprimo.Repo,
  database: "elprimo_repo",
  username: "postgres",
  password: "elprimo",
  hostname: "localhost"

config :elprimo, ecto_repos: [Elprimo.Repo]

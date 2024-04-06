import Config

config :telegex, caller_adapter: {Finch, [receive_timeout: 5 * 1000]}
import_config("secret.exs")

config :elprimo, Elprimo.Repo,
  database: "elprimo_repo",
  username: "postgres",
  password: "elprimo",
  hostname: "localhost"

config :elprimo, ecto_repos: [Elprimo.Repo]

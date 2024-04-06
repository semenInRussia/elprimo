defmodule Elprimo.Repo do
  use Ecto.Repo,
    otp_app: :elprimo,
    adapter: Ecto.Adapters.Postgres
end

defmodule Elprimo.Repo.Migrations.BigintTelegramId do
  use Ecto.Migration

  def change do
    alter table("user") do
      modify(:telegram, :bigint)
    end
  end
end

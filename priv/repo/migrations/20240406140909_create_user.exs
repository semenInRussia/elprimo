defmodule Elprimo.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table("user") do
      add(:username, :string)
      add(:telegram, :integer, null: false)
      add(:admin, :bool)
    end
  end
end

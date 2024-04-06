defmodule Elprimo.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table("question") do
      add(:text, :string)
      add(:from, references(:user))
      add(:time, :naive_datetime)
      add(:isquery, :bool)
    end
  end
end

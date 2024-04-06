defmodule Elprimo.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table("message") do
      add(:text, :string)
      add(:prev, references("message"))
      add(:from, references("user"))
      add(:to, references("user"))
      add(:time, :naive_datetime)
    end
  end
end

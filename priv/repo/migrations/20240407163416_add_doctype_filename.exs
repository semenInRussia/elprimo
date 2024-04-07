defmodule Elprimo.Repo.Migrations.AddDoctypeFilename do
  use Ecto.Migration

  def change do
    alter table("doctype") do
      add(:filename, :string)
    end
  end
end

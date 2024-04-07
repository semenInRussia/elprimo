defmodule Elprimo.Repo.Migrations.AddDoctypeDescription do
  use Ecto.Migration

  def change do
    alter table(:doctype) do
      add(:description, :string)
    end
  end
end

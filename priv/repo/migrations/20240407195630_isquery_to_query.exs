defmodule Elprimo.Repo.Migrations.IsqueryToQuery do
  use Ecto.Migration

  def change do
    alter table("question") do
      add(:query, references("query"))
      remove(:isquery)
    end
  end
end

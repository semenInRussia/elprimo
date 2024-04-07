defmodule Elprimo.Repo.Migrations.CreateQuery do
  use Ecto.Migration

  def change do
    create table("doctype") do
      add(:name, :string, null: false)
    end

    create table("query") do
      add(:info, :string, null: false)
      add(:doctype, references("doctype"), null: false)
    end

    create table("field") do
      add(:doctype, references("doctype"), null: false)
      add(:number, :integer, null: false)
      add(:prompt, :string, null: false)
      add(:default, :string)
    end
  end
end

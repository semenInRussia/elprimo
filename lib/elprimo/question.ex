defmodule Elprimo.Question do
  @moduledoc """
  A schema for Elprimo.Question for sync with Database.
  """

  use Ecto.Schema

  schema "question" do
    field(:text, :string)
    field(:from, :integer)
    field(:time, :naive_datetime)
    field(:isquery, :boolean)
  end
end

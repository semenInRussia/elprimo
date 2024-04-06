defmodule Elprimo.Message do
  use Ecto.Schema

  schema "message" do
    field(:text, :string)
    field(:prev, :integer)
    field(:from, :integer)
    field(:to, :integer)
    field(:time, :naive_datetime)
  end
end

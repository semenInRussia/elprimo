defmodule Elprimo.Doctype do
  @moduledoc """
  A schema of Doctype -- type of the document query.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  schema "doctype" do
    field(:name, :string)
    field(:filename, :string)
  end
end

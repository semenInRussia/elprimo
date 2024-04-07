defmodule Elprimo.Field do
  @moduledoc """
  A schema of Field -- a field of more big query to print a document
  with the certain format.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  schema "field" do
    field(:doctype, :integer)
    field(:number, :integer)
    field(:prompt, :string)
    field(:default, :string)
  end
end

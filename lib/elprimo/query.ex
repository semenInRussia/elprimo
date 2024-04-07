defmodule Elprimo.Query do
  @moduledoc """
  A schema of Query -- a query to print the document inside the school.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  schema "query" do
    field(:info, :string)
    field(:doctype, :integer)
  end
end

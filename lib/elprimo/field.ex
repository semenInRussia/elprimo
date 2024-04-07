defmodule Elprimo.Field do
  @moduledoc """
  A schema of Field -- a field of more big query to print a document
  with the certain format.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  import Ecto.Query

  @type t() :: %__MODULE__{}

  schema "field" do
    field(:doctype, :integer)
    field(:number, :integer)
    field(:prompt, :string)
    field(:default, :string)
  end

  @spec find(integer(), integer()) :: t() | nil
  def find(doctype_id, number) do
    query =
      from(f in __MODULE__,
        where: f.doctype == ^doctype_id and f.number == ^number,
        select: f
      )

    Elprimo.Repo.one(query)
  end
end

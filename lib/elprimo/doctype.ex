defmodule Elprimo.Doctype do
  @moduledoc """
  A schema of Doctype -- type of the document query.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  import Ecto.Query

  @type t() :: %__MODULE__{}

  schema "doctype" do
    field(:name, :string)
    field(:filename, :string)
    field(:description, :string)
  end

  @spec by_name(String.t()) :: nil | t()
  def by_name(name) do
    query = from(d in __MODULE__, where: d.name == ^name, select: d)
    Elprimo.Repo.one(query)
  end

  @spec by_id(integer()) :: nil | t()
  def by_id(id) do
    query = from(d in __MODULE__, where: d.id == ^id, select: d)
    Elprimo.Repo.one(query)
  end

  @spec all() :: list(t())
  def all() do
    query = from(d in __MODULE__, select: d)
    Elprimo.Repo.all(query)
  end

  def fields(%__MODULE__{} = d) do
    query = from(f in Elprimo.Field, where: f.doctype == ^d.id, select: f)
    Elprimo.Repo.all(query)
  end
end

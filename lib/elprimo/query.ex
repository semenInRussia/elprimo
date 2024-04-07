defmodule Elprimo.Query do
  @moduledoc """
  A schema of Query -- a query to print the document inside the school.

  NOTE that schemes are used for sync with database
  """

  @templates_path "templates/"
  @extension ".docx"

  use Ecto.Schema

  import Ecto.Query
  require Logger

  import Elprimo.Utils

  @type t() :: %__MODULE__{}

  schema "query" do
    field(:info, :string)
    field(:doctype, :integer)
  end

  def separator() do
    "|||"
  end

  def publish(%__MODULE__{} = q) do
    publish(gen_pdf(q))
  end

  def publish(str) do
    filename = @templates_path <> UUID.uuid4() <> @extension
    File.write(filename, str)
    filename
  end

  def gen_pdf(%__MODULE__{} = q) do
    d = Elprimo.Doctype.by_id(q.doctype)
    fields = Elprimo.Doctype.fields(d)

    keys =
      Range.new(1, length(fields))
      |> Enum.map(&("{{{" <> Integer.to_string(&1) <> "}}}"))

    vals = String.split(q.info, separator(), trim: true)

    m = Enum.zip(keys, vals) |> Map.new()

    Logger.warning(keys)

    {:ok, txt} = File.read(@templates_path <> d.filename)

    String.replace(txt, keys, &Map.get(m, &1))
  end

  @spec by_id(integer()) :: t()
  def by_id(id) do
    query = from(q in __MODULE__, where: q.id == ^id, select: q)
    Elprimo.Repo.one(query)
  end

  def save_and_send_to_admins(%__MODULE__{} = q, %Elprimo.User{} = user) do
    {:ok, query} = Elprimo.Repo.insert(q)
    d = Elprimo.Doctype.by_id(q.doctype)

    {:ok, q} =
      Elprimo.Repo.insert(%Elprimo.Question{
        text: "Запрос на документ типа \"#{d.name}\"",
        from: user.id,
        query: query.id,
        time: now()
      })

    Elprimo.Question.send_to_admins(q)
  end
end

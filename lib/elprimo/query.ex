# _queries/bdc09491-9e79-4d32-b918-614e686569da/word/document.xml

defmodule Elprimo.Query do
  @moduledoc """
  A schema of Query -- a query to print the document inside the school.

  NOTE that schemes are used for sync with database
  """
  require Logger

  @templates_path "templates/"
  @dest_path "_queries/"
  @extension ".docx"

  use Ecto.Schema

  import Ecto.Query
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
    d = Elprimo.Doctype.by_id(q.doctype)
    template = @templates_path <> d.filename
    filename = @dest_path <> UUID.uuid4() <> @extension

    args =
      for {old, new} <- replacements(q, d) do
        "#{old}=#{new}"
      end

    Logger.warning(args)

    System.cmd("docx-replace", [template, "--pattern"] ++ args ++ ["-o", filename])

    filename
  end

  defp replacements(%__MODULE__{} = q, %Elprimo.Doctype{} = d) do
    fields = Elprimo.Doctype.fields(d)

    keys =
      Range.new(1, length(fields))
      |> Enum.map(&("{{{" <> Integer.to_string(&1) <> "}}}"))

    vals = String.split(q.info, separator(), trim: true)
    time = now()

    Enum.zip(keys, vals)
    |> Map.new()
    |> Map.put("{{{date}}}", time.day)
    |> Map.put("{{{month}}}", time.month)
    |> Map.put("{{{year}}}", time.year)
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

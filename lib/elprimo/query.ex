defmodule Elprimo.Query do
  @moduledoc """
  A schema of Query -- a query to print the document inside the school.

  NOTE that schemes are used for sync with database
  """

  use Ecto.Schema

  import Elprimo.Utils

  schema "query" do
    field(:info, :string)
    field(:doctype, :integer)
  end

  def save_and_send_to_admins(%__MODULE__{} = q, %Elprimo.User{} = user) do
    Elprimo.Repo.insert(q)
    d = Elprimo.Doctype.by_id(q.doctype)

    {:ok, q} =
      Elprimo.Repo.insert(%Elprimo.Question{
        text: "Запрос на документ типа \"#{d.name}\"",
        from: user.id,
        isquery: true,
        time: now()
      })

    Elprimo.Question.send_to_admins(q)
  end
end

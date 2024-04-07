defmodule Elprimo.Question do
  @moduledoc """
  A schema for Elprimo.Question for sync with Database.
  """

  use Ecto.Schema
  import Ecto.Query

  schema "question" do
    field(:text, :string)
    field(:from, :integer)
    field(:time, :naive_datetime)
    field(:isquery, :boolean)
  end

  def send_to_telegram(%__MODULE__{} = q, %Elprimo.User{} = u) do
    text =
      "_Автор вопроса_: \#u#{q.from}\n" <>
        "_Время_: #{q.time}\n" <>
        "\n#{q.text}\n"

    kb = %{
      inline_keyboard: [
        [%{text: "Ответить", callback_data: "/answ#{q.id}"}]
      ]
    }

    Telegex.send_message(
      u.telegram,
      text,
      reply_markup: kb,
      parse_mode: "markdown"
    )
  end

  def by_id(id) do
    query = from(q in __MODULE__, where: q.id == ^id, select: q)
    Elprimo.Repo.one(query)
  end
end

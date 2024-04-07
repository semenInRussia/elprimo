defmodule Elprimo.Question do
  @moduledoc """
  A schema for Elprimo.Question for sync with Database.
  """
  alias Telegex.Type.InlineKeyboardButton
  alias Telegex.Type.InlineKeyboardMarkup

  use Ecto.Schema
  import Ecto.Query
  import Elprimo.Utils

  @type t() :: %__MODULE__{}

  schema "question" do
    field(:text, :string)
    field(:from, :integer)
    field(:time, :naive_datetime)
    field(:isquery, :boolean)
  end

  def send_to_telegram(%__MODULE__{} = q, %Elprimo.User{} = u) do
    text =
      "_Время_: #{format_date(q.time)}\n" <>
        "_Автор_: \#u#{q.from}\n" <>
        "\n#{q.text}\n"

    kb = %InlineKeyboardMarkup{
      inline_keyboard: [
        [
          %InlineKeyboardButton{text: "Ответить", callback_data: "/answ#{q.id}"}
        ]
      ]
    }

    Telegex.send_message(
      u.telegram,
      text,
      reply_markup: kb,
      parse_mode: "markdown"
    )
  end

  @spec by_id(integer()) :: t() | nil
  def by_id(id) do
    query = from(q in __MODULE__, where: q.id == ^id, select: q)
    Elprimo.Repo.one(query)
  end
end

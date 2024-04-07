defmodule Elprimo.Question do
  @moduledoc """
  A schema for Elprimo.Question for sync with Database.
  """
  require Logger
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
    field(:query, :integer)
  end

  @spec send_to_admins(t()) :: any()
  def send_to_admins(%__MODULE__{} = q) do
    for u <- Elprimo.User.admins() do
      Task.async(__MODULE__, :send_to_telegram, [q, u])
    end
    |> Task.await_many()
  end

  def send_to_telegram(%__MODULE__{} = q, %Elprimo.User{} = u) do
    text =
      "_Время_: #{format_date(q.time)}\n" <>
        "_Автор_: \#u#{q.from}\n" <>
        "\n#{q.text}\n"

    kb = %InlineKeyboardMarkup{
      inline_keyboard: [
        [%InlineKeyboardButton{text: "Ответить", callback_data: "/answ#{q.id}"}]
      ]
    }

    document =
      q.query && q.query |> Elprimo.Query.by_id() |> Elprimo.Query.publish()

    Telegex.send_message(
      u.telegram,
      text,
      parse_mode: "markdown",
      reply_markup: kb
    )

    Logger.warning(document)

    if document do
      Telegex.send_document(u.telegram, document)
    end
  end

  @spec by_id(integer()) :: t() | nil
  def by_id(id) do
    query = from(q in __MODULE__, where: q.id == ^id, select: q)
    Elprimo.Repo.one(query)
  end
end

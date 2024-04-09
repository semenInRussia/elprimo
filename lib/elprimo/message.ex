defmodule Elprimo.Message do
  alias Telegex.Type.InlineKeyboardButton
  alias Telegex.Type.InlineKeyboardMarkup
  use Ecto.Schema

  import Elprimo.Utils
  import Ecto.Query

  @type t() :: %__MODULE__{}

  schema "message" do
    field(:text, :string)
    field(:prev, :integer)
    field(:from, :integer)
    field(:to, :integer)
    field(:time, :naive_datetime)
  end

  def send_to_telegram(%__MODULE__{} = m, %Elprimo.User{} = u) do
    text =
      "Вам ответили!\n" <>
        "_Время_: #{format_date(m.time)}\n" <>
        "_Автор_: \#u#{m.from}\n" <>
        "\n" <>
        "#{m.text}"

    buts =
      [
        %InlineKeyboardButton{
          text: "Продолжить",
          callback_data: "/msg#{m.id}"
        }
      ] ++
        if u.admin do
          [
            %InlineKeyboardButton{
              text: "Скинуть всем",
              callback_data: "/forall#{m.id}"
            }
          ]
        else
          []
        end

    kb = %InlineKeyboardMarkup{inline_keyboard: [buts]}

    Telegex.send_message(
      u.telegram,
      text,
      parse_mode: "markdown",
      reply_markup: kb
    )
  end

  def send_to_admins(%__MODULE__{} = m) do
    for u <- Elprimo.User.admins() do
      Task.async(__MODULE__, :send_to_telegram, [m, u])
    end
    |> Task.await_many()
  end

  @spec by_id(integer()) :: t() | nil
  def by_id(id) do
    query = from(m in __MODULE__, where: m.id == ^id, select: m)
    Elprimo.Repo.one(query)
  end
end

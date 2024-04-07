defmodule Elprimo.Message do
  use Ecto.Schema
  import Elprimo.Utils

  schema "message" do
    field(:text, :string)
    field(:prev, :integer)
    field(:from, :integer)
    field(:to, :integer)
    field(:time, :naive_datetime)
  end

  def send_to_telegram(%__MODULE__{} = m, %Elprimo.User{} = u) do
    text =
      "Вам ответили!!\n" <>
        "_Время_: #{format_date(m.time)}\n" <>
        "_Автор_: \#u#{m.from}\n" <>
        "\n" <>
        "#{m.text}"

    Telegex.send_message(u.telegram, text, parse_mode: "markdown")
  end
end

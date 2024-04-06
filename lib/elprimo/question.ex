defmodule Elprimo.Question do
  @moduledoc """
  A schema for Elprimo.Question for sync with Database.
  """

  use Ecto.Schema

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
        "\n#{q.text}\n" <>
        "\n" <>
        "/answ#{q.id}"

    Telegex.send_message(
      u.telegram,
      text,
      parse_mode: "markdown"
    )
  end
end

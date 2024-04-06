defmodule Elprimo.Handlers.QuestionHandler do
  use Telegex.Chain, :message
  alias Elprimo.Question
  alias Elprimo.User
  alias Telegex.Type.Message
  import Elprimo.Utils

  @command "/question"

  require Logger

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    msg.text
    |> String.trim()
    |> String.contains?(@command)
  end

  def match?(_msg, _ctx) do
    false
  end

  @impl Telegex.Chain
  def handle(%Message{from: user, text: txt} = msg, context) do
    Logger.warning(msg)

    u = User.by_telegram_id(user.id)
    txt = txt |> String.replace(@command, "") |> String.trim()

    Elprimo.Repo.insert(%Question{time: now(), from: u.id, text: txt, isquery: false})

    Telegex.send_message(msg.chat.id, "Спасибо за то, что задали вопрос!")

    {:done, context}
  end
end

defmodule Elprimo.Handlers.QuestionHandler do
  use Telegex.Chain, :message
  alias Elprimo.Question
  alias Elprimo.User
  alias Elprimo.State
  alias Telegex.Type.Message
  import Elprimo.Utils

  @command "question"

  require Logger

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    check_command(msg.text, @command) or State.check(msg.from.id, :question)
  end

  def match?(_msg, _ctx) do
    false
  end

  @impl Telegex.Chain
  def handle(%Message{from: user} = msg, context) do
    handle_state(State.get(user.id), msg, context)
  end

  def handle_state(state, %Message{from: user, text: txt} = msg, ctx) do
    u = User.by_telegram_id(user.id)

    case state do
      :question ->
        Elprimo.Repo.insert(%Question{time: now(), from: u.id, text: txt, isquery: false})
        Telegex.send_message(msg.chat.id, "Спасибо за то, что задали вопрос!")
        State.update(user.id, :none)

      :none ->
        Telegex.send_message(msg.chat.id, "Ваш вопрос (как можно конкретнее)?")
        State.update(user.id, :question)
    end

    {:done, ctx}
  end
end

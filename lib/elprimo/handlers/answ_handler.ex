defmodule Elprimo.Handlers.AnswHandler do
  use Telegex.Chain, :message
  alias Elprimo.Question
  alias Telegex.Type.Message
  alias Elprimo.User
  alias Elprimo.State
  import Elprimo.Utils

  @command "answ"

  require Logger

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    chop_1arg_command(msg.text, @command) || Kernel.match?({:answer, _}, State.get(msg.from.id))
  end

  def match?(_msg, _ctx), do: false

  @impl Telegex.Chain
  def handle(%Message{from: user} = msg, context) do
    u = User.by_telegram_id(user.id)

    if not u.admin do
      Telegex.send_message(user.id, "Вы не админ, никак!")
    else
      handle_state(State.get(user.id), msg, u, context)
    end
  end

  def handle_state(state, %Message{from: user, text: txt} = msg, u, ctx) do
    case state do
      {:answer, question_id} ->
        q = Question.by_id(question_id)

        Elprimo.Repo.insert(%Elprimo.Message{
          text: txt,
          to: q.from,
          from: u.id,
          time: now()
        })

        State.update(user.id, :none)

        Telegex.send_message(user.id, "Вы ответили человеку на его вопрос, достойно уважения")

      :none ->
        question_id = chop_1arg_command(txt, @command)
        Telegex.send_message(msg.chat.id, "Ваш ответ:")
        State.update(user.id, {:answer, question_id})
    end

    {:done, ctx}
  end
end

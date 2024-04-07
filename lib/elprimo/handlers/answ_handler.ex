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
  def handle(%Message{from: user, text: text}, context) do
    u = User.by_telegram_id(user.id)

    if not u.admin do
      Telegex.send_message(u.telegram, "Вы не админ, никак!")
    else
      state = State.get(user.id)
      next_state(state, text, u, context)
    end
  end

  def next_state(state, text, %Elprimo.User{} = user, ctx) do
    case state do
      {:answer, question_id} ->
        q = Question.by_id(question_id)

        Elprimo.Repo.insert(%Elprimo.Message{
          text: text,
          to: q.from,
          from: user.id,
          time: now()
        })

        Telegex.send_message(
          user.telegram,
          "Вы ответили человеку на его вопрос, достойно уважения"
        )

        State.update(user.telegram, :none)

      :none ->
        question_id = chop_1arg_command(text, @command)
        Telegex.send_message(user.telegram, "Ваш ответ:")
        State.update(user.telegram, {:answer, question_id})
    end

    {:done, ctx}
  end
end

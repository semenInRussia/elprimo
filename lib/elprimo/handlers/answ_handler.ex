defmodule Elprimo.Handlers.AnswHandler do
  alias Elprimo.Question
  alias Elprimo.State
  alias Elprimo.User
  alias Telegex.Type.Update
  import Elprimo.Utils
  use Telegex.Chain

  @command "answ"

  require Logger

  @impl Telegex.Chain
  def match?(%Update{} = upd, _ctx)
      when not is_nil(upd.callback_query) or not is_nil(upd.message) do
    text = text_of_update(upd)
    tg_id = tg_of_update(upd)
    state = State.get(tg_id)
    chop_1arg_command(text, @command) || Kernel.match?({:answer, _}, state)
  end

  def match?(_msg, _ctx), do: false

  def text_of_update(%Update{} = upd) do
    cond do
      upd.callback_query != nil ->
        upd.callback_query.data

      upd.message != nil ->
        upd.message.text
    end
  end

  def tg_of_update(%Update{} = upd) do
    cond do
      upd.callback_query != nil ->
        upd.callback_query.from.id

      upd.message != nil ->
        upd.message.from.id
    end
  end

  @impl Telegex.Chain
  def handle(%Update{} = upd, context) do
    tg_id = tg_of_update(upd)
    u = User.by_telegram_id(tg_id)
    text = text_of_update(upd)

    if not u.admin do
      Telegex.send_message(u.telegram, "Вы не админ, никак!")
    else
      state = State.get(tg_id)
      next_state(state, text, u, context)
    end
  end

  def next_state(state, text, %Elprimo.User{} = user, ctx) do
    case state do
      {:answer, question_id} ->
        q = Question.by_id(question_id)
        save_and_send(text, user.id, q.from)

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

  def save_and_send(text, from, to) do
    {:ok, m} =
      Elprimo.Repo.insert(%Elprimo.Message{
        text: text,
        to: to,
        from: from,
        time: now()
      })

    u = Elprimo.User.by_id(to)
    Elprimo.Message.send_to_telegram(m, u)
  end
end

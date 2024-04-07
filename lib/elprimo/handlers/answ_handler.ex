defmodule Elprimo.Handlers.AnswHandler do
  @moduledoc """
  Handle /answ<id> command or a callback query with /answ<id> data
  which are called when an admin press "Answer" at the question bottom
  inline query
  """

  use Telegex.Chain

  alias Elprimo.{Question, State, User}
  alias Telegex.Type.Update
  import Elprimo.Utils

  @command "answ"

  require Logger

  @impl Telegex.Chain
  def match?(%Update{callback_query: cb, message: msg}, _ctx) do
    cond do
      !(cb && cb.from) && !(msg && msg.from) ->
        false

      cb != nil && chop_1arg_command(cb.data || "", @command) ->
        State.check(cb.from.id, :none)

      msg != nil && chop_1arg_command(msg.text || "", @command) ->
        State.check(msg.from.id, :none)

      msg != nil ->
        Kernel.match?({:answer, _}, State.get(msg.chat.id))

      cb != nil ->
        Kernel.match?({:answer, _}, State.get(cb.from.id))
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
      next_state(state, text, u)
      {:done, context}
    end
  end

  def next_state(state, text, %Elprimo.User{} = user) do
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
end

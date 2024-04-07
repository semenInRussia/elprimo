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
  def match?(%Update{callback_query: cb, message: msg}, _ctx)
      when is_nil(cb) and is_nil(msg) do
    false
  end

  def match?(%Update{callback_query: cb, message: msg}, _ctx) do
    {text, tg} =
      cond do
        cb && cb.message && cb.message.chat && cb.message.chat.id ->
          {cb.data || "", cb.message.chat.id}

        msg && msg.from ->
          {msg.text || "", msg.from.id}

        true ->
          {"", nil}
      end

    state = tg && State.get(tg)

    case chop_1arg_command(text, @command) do
      false -> Kernel.match?({:answer, _}, state)
      _id -> state == :none
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

      _ ->
        need_cancel(user)
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

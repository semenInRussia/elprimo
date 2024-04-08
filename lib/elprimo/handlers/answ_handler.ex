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

  @impl Telegex.Chain
  def match?(%Update{callback_query: cb, message: msg}, _ctx)
      when is_nil(cb) and is_nil(msg) do
    false
  end

  def match?(%Update{callback_query: cb, message: msg}, _ctx) do
    cond do
      msg ->
        state = State.get(msg.from.id)
        msg.text && msg.from && Kernel.match?({:answer, _}, state)

      cb ->
        text = cb.data || ""
        chop_1arg_command(text, @command)

      true ->
        false
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

  @spec next_state(State.t(), String.t(), Elprimo.User.t()) :: any()
  def next_state(state, text, %Elprimo.User{} = user) do
    case state do
      {:answer, question_id} ->
        q = Question.by_id(question_id)
        save_and_send(text, user.id, q.from)

        Telegex.send_message(
          user.telegram,
          "Ваш вопрос уже отправлен..."
        )

        State.update(user.telegram, :none)

      :none ->
        question_id = chop_1arg_command(text, @command)
        Telegex.send_message(user.telegram, "Ваш ответ на этот прекрасный вопрос:")
        State.update(user.telegram, {:answer, question_id})

      _ ->
        need_cancel(user)
    end
  end

  @spec save_and_send(String.t(), integer(), integer()) :: any()
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

  @spec text_of_update(%Update{}) :: String.t() | nil
  def text_of_update(%Update{} = upd) do
    cond do
      upd.callback_query != nil ->
        upd.callback_query.data

      upd.message != nil ->
        upd.message.text
    end
  end

  @spec tg_of_update(%Update{}) :: integer() | nil
  def tg_of_update(%Update{} = upd) do
    cond do
      upd.callback_query != nil ->
        upd.callback_query.message.chat.id

      upd.message != nil ->
        upd.message.from.id
    end
  end
end

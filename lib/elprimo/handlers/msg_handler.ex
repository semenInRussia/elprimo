defmodule Elprimo.Handlers.MsgHandler do
  @moduledoc """
  Handle an answer on answer.

  This command called /msg<id> or can be called when callback query is
  sent with /msg<id>
  """

  use Telegex.Chain

  import Elprimo.Utils
  alias Elprimo.State

  alias Telegex.Type.Update

  @command "msg"

  @impl Telegex.Chain
  def match?(%Update{message: msg, callback_query: cb}, _context) do
    cond do
      msg && msg.from ->
        state = State.get(msg.from.id)
        Kernel.match?({:msg, _}, state)

      cb ->
        text = cb.data || ""
        chop_1arg_command(text, @command)

      true ->
        false
    end
  end

  @impl Telegex.Chain
  def handle(%Update{message: msg, callback_query: cb}, context) do
    {text, state, tg} =
      cond do
        msg -> {msg.text, State.get(msg.from.id), msg.from.id}
        cb -> {cb.data, State.get(cb.message.chat.id), cb.message.chat.id}
      end

    user = Elprimo.User.by_telegram_id(tg)

    next_state(state, text, user)
    {:done, context}
  end

  @spec next_state(State.t(), String.t(), Elprimo.User.t()) :: any()
  def next_state(state, text, %Elprimo.User{} = user) do
    case state do
      :none ->
        msg_id = chop_1arg_command(text, @command)
        msg = Elprimo.Message.by_id(msg_id)

        if msg.from != user.id and msg.to != user.id do
          Telegex.send_message(
            user.telegram,
            "У тебя нет прав на то, чтобы ответить на это сообщение, кретин"
          )
        else
          Telegex.send_message(user.telegram, "Что вы скажете на это?")
          State.update(user.telegram, {:msg, msg_id})
        end

      {:msg, msg_id} ->
        prev = Elprimo.Message.by_id(msg_id)
        save_and_send(text, prev)

        Telegex.send_message(user.telegram, "Отправлено!")
        State.update(user.telegram, :none)

      _ ->
        need_cancel(user)
    end
  end

  @spec save_and_send(String.t(), Elprimo.Message.t()) :: any()
  def save_and_send(text, %Elprimo.Message{} = prev) do
    {:ok, m} =
      Elprimo.Repo.insert(%Elprimo.Message{
        text: text,
        prev: prev.id,
        from: prev.to,
        to: prev.from,
        time: now()
      })

    u = Elprimo.User.by_id(prev.from)
    Elprimo.Message.send_to_telegram(m, u)
  end
end

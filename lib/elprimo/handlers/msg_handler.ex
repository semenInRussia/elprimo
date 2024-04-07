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
    state =
      cond do
        not is_nil(msg && msg.from) -> State.get(msg.from.id)
        not is_nil(cb && cb.message) -> State.get(cb.message.chat.id)
      end

    cond do
      !msg && !cb ->
        false

      Kernel.match?({:msg, _}, state) ->
        true

      not is_nil(msg) ->
        chop_1arg_command(msg.text || "", @command)

      not is_nil(cb) ->
        chop_1arg_command(cb.data || "", @command)
    end
  end

  @impl Telegex.Chain
  def handle(%Update{message: msg, callback_query: cb}, context) do
    cond do
      !(msg && msg.text) && !(cb && cb.from) ->
        Telegex.send_message(msg.from.id, "Пришлите ваш ответ или отмените /cancel")
        {:done, context}

      true ->
        {text, state, tg} =
          cond do
            msg -> {msg.text, State.get(msg.from.id), msg.from.id}
            cb -> {cb.data, State.get(cb.message.chat.id), cb.message.chat.id}
          end

        user = Elprimo.User.by_telegram_id(tg)

        next_state(state, text, user)
        {:done, context}
    end
  end

  def next_state(state, text, %Elprimo.User{} = user) do
    case state do
      :none ->
        msg_id = chop_1arg_command(text, @command)
        Telegex.send_message(user.telegram, "Ваш ответ:")
        State.update(user.telegram, {:msg, msg_id})

      {:msg, msg_id} ->
        prev = Elprimo.Message.by_id(msg_id)

        Elprimo.Repo.insert(%Elprimo.Message{
          text: text,
          prev: prev.id,
          from: prev.to,
          to: prev.from,
          time: now()
        })

        Telegex.send_message(user.telegram, "Отправлено!")
        State.update(user.telegram, :none)
    end
  end
end

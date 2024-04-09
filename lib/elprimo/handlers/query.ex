defmodule Elprimo.Handlers.Query do
  @moduledoc """
  Handle all income Telegram updates which touch a query generation.
  """

  use Telegex.Chain

  import Elprimo.Utils

  require Logger

  alias Telegex.Type.InlineKeyboardButton
  alias Telegex.Type.InlineKeyboardMarkup
  alias Telegex.Type.Update
  alias Elprimo.State

  @command "query"

  def label() do
    "Запрос на Документы 📃"
  end

  @impl Telegex.Chain
  def match?(%Update{message: msg} = _upd, _context) do
    cond do
      msg && msg.from && msg.text && check_command(msg.text, @command) ->
        true

      msg && msg.from && msg.text && msg.text == label() ->
        true

      msg && msg.from ->
        state = State.get(msg.from.id)
        Kernel.match?({:query_field, _, _, _}, state) || state == :query_type

      true ->
        false
    end
  end

  @impl Telegex.Chain
  def handle(%Update{message: msg} = _upd, context) do
    user = Elprimo.User.by_telegram_id(msg.from.id)
    text = msg.text
    state = State.get(user.telegram)
    next_state(state, user, text)
    {:done, context}
  end

  @spec next_state(State.t(), Elprimo.User.t(), String.t()) :: any()
  def next_state(state, %Elprimo.User{} = user, text) do
    case state do
      :none ->
        kb = %InlineKeyboardMarkup{
          inline_keyboard: [
            [%InlineKeyboardButton{text: "Выбрать", switch_inline_query_current_chat: ""}]
          ]
        }

        Telegex.send_message(user.telegram, "Запрос на какой документ хотите подавать?",
          reply_markup: kb
        )

        State.update(user.telegram, :query_type)

      :query_type ->
        doctype = Elprimo.Doctype.by_name(text)

        if doctype == nil do
          Telegex.send_message(
            user.telegram,
            "Неправильный тип документа, попробуйте ещё раз!  Если что вы можете увидеть список возможных документов, нажав кнопку \"Выбрать\" сверху.  Ещё возможно вам необходимо отменить текущую операцию, нажав /cancel"
          )
        else
          State.update(user.telegram, {:query_field, 2, doctype.id, ""})
          next_field_question(user, 1, doctype.id)
        end

      {:query_field, number, doctype_id, info} ->
        # so text is answer on previous field question
        State.update(
          user.telegram,
          {:query_field, number + 1, doctype_id, info <> Elprimo.Query.separator() <> text}
        )

        next_field_question(user, number, doctype_id)

      _ ->
        need_cancel(user)
    end
  end

  @spec next_field_question(Elprimo.User.t(), integer(), integer()) :: any()
  def next_field_question(user, number, doctype_id) do
    a = ask_field_question(user, number, doctype_id)

    unless a do
      stop_gen_query(user)
    end
  end

  @doc """
  Ask field question with the given number the user.

  If next questions are exists return true, otherwise false.
  """
  @spec ask_field_question(Elprimo.User.t(), integer(), integer()) :: boolean()
  def ask_field_question(user, number, doctype_id) do
    field = Elprimo.Field.find(doctype_id, number)

    if field do
      Telegex.send_message(user.telegram, field.prompt)
      true
    else
      false
    end
  end

  def stop_gen_query(%Elprimo.User{} = user) do
    state = State.get(user.telegram)

    with {:query_field, _number, doctype_id, info} <- state do
      q = %Elprimo.Query{doctype: doctype_id, info: info}
      Elprimo.Query.save_and_send_to_admins(q, user)

      Telegex.send_message(
        user.telegram,
        "Ваша заявка на получения документа получена, приходите в школу в рабочие часы приёмной"
      )

      State.update(user.telegram, :none)
    else
      _ -> Logger.error("We can't call `stop_gen_query` when state isn't :query_field")
    end
  end
end

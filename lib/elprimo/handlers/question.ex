defmodule Elprimo.Handlers.Question do
  @moduledoc """
  Handle an ask question.
  """

  use Telegex.Chain, :message

  alias Elprimo.Question
  alias Elprimo.State
  alias Telegex.Type.Message
  import Elprimo.Utils

  @command "question"

  def label() do
    "Задать Вопрос 🤔"
  end

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    label() == msg.text or check_command(msg.text, @command) or
      State.check(msg.from.id, :question)
  end

  def match?(_msg, _ctx), do: false

  @impl Telegex.Chain
  def handle(%Message{from: user} = msg, context) do
    u = Elprimo.User.by_telegram_id(user.id)
    state = State.get(user.id)
    next_state(state, msg.text, u)
    {:done, context}
  end

  def next_state(state, text, %Elprimo.User{} = user) do
    case state do
      :question ->
        save_and_send(user, text)

        Telegex.send_message(
          user.telegram,
          "Ваш вопрос отправлен, дожидайтесь ответа! Он придёт в скором времени"
        )

        State.update(user.telegram, :none)

      :none ->
        Telegex.send_message(user.telegram, "Ваш вопрос (как можно конкретнее)?")
        State.update(user.telegram, :question)

      _ ->
        need_cancel(user)
    end
  end

  @spec save_and_send(Elprimo.User.t(), String.t()) :: any()
  def save_and_send(%Elprimo.User{} = user, text) do
    {:ok, q} =
      Elprimo.Repo.insert(%Question{time: now(), from: user.id, text: text, query: nil})

    Elprimo.Question.send_to_admins(q)
  end
end

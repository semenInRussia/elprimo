defmodule Elprimo.Handlers.QuestionHandler do
  @moduledoc """
  Handle an ask question.
  """

  use Telegex.Chain, :message

  alias Elprimo.Question
  alias Elprimo.State
  alias Telegex.Type.Message
  import Elprimo.Utils

  @command "question"

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    check_command(msg.text, @command) or State.check(msg.from.id, :question)
  end

  def match?(_msg, _ctx) do
    false
  end

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
        Telegex.send_message(user.telegram, "Спасибо за то, что задали вопрос!")
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
      Elprimo.Repo.insert(%Question{time: now(), from: user.id, text: text, isquery: false})

    send_to_admins(q)
  end

  @spec send_to_admins(Elprimo.Question.t()) :: any()
  def send_to_admins(%Elprimo.Question{} = q) do
    for u <- Elprimo.User.admins() do
      Task.async(Question, :send_to_telegram, [q, u])
    end
    |> Task.await_many()
  end
end

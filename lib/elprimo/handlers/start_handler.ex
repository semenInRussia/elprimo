defmodule Elprimo.Handlers.StartHandler do
  use Telegex.Chain, :message
  alias Elprimo.User
  alias Telegex.Type.Message

  @command "/start"

  require Logger

  @impl Telegex.Chain
  def match?(msg, _ctx) when not is_nil(msg.text) do
    msg.text
    |> String.trim()
    |> String.equivalent?(@command)
  end

  def match?(_msg, _ctx) do
    false
  end

  @impl Telegex.Chain
  def handle(%Message{from: user} = msg, context) do
    Logger.warning(msg)

    if is_nil(Elprimo.User.by_telegram_id(user.id)) do
      Elprimo.Repo.insert(User.from_tgx(user))
    end

    Telegex.send_message(msg.chat.id, "Дарово!! |/ 🤝")

    {:done, context}
  end
end

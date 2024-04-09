defmodule Elprimo.Handlers.Start do
  @moduledoc """
  Handle the /start command.

  After user call /start their Telegram ID is stored to DB
  """

  use Telegex.Chain, :message
  alias Telegex.Type.KeyboardButton
  alias Telegex.Type.ReplyKeyboardMarkup
  alias Elprimo.User
  alias Telegex.Type.Message
  import Elprimo.Utils

  @command "start"

  @impl Telegex.Chain
  def match?(msg, _ctx) do
    check_command(msg.text, @command)
  end

  @impl Telegex.Chain
  def handle(%Message{from: user} = msg, context) do
    if is_nil(Elprimo.User.by_telegram_id(user.id)) do
      Elprimo.Repo.insert(User.from_tgx(user))
    end

    kb = %ReplyKeyboardMarkup{
      keyboard: [
        [%KeyboardButton{text: Elprimo.Handlers.Query.label()}],
        [%KeyboardButton{text: Elprimo.Handlers.Question.label()}]
      ]
    }

    Telegex.send_message(msg.chat.id, "Дарово!! |/ 🤝", reply_markup: kb)

    {:done, context}
  end
end

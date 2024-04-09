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
    u =
      case Elprimo.User.by_telegram_id(user.id) do
        nil ->
          user = User.from_tgx(user)
          Elprimo.Repo.insert(user)
          user

        user ->
          user
      end

    Telegex.send_message(msg.chat.id, "Дарово!! |/ 🤝", reply_markup: keyboard(u))

    {:done, context}
  end

  def keyboard(%Elprimo.User{} = u) do
    %ReplyKeyboardMarkup{
      keyboard: [
        [%KeyboardButton{text: Elprimo.Handlers.Query.label()}],
        [%KeyboardButton{text: Elprimo.Handlers.Question.label()}],
        [%KeyboardButton{text: Elprimo.Handlers.Cancel.label()}] ++
          if u.admin do
            [%KeyboardButton{text: Elprimo.Handlers.AddAdmins.label()}]
          else
            []
          end
      ]
    }
  end
end

defmodule Elprimo.Handlers.AddAdmins do
  @moduledoc """
  Handle a command from Telegram to adding new admins.
  """

  use Telegex.Chain

  require Logger

  import Elprimo.Utils

  alias Elprimo.State
  alias Telegex.Type.KeyboardButtonRequestUsers
  alias Telegex.Type.KeyboardButton
  alias Telegex.Type.ReplyKeyboardMarkup
  alias Telegex.Type.Update

  @command "addadmins"

  def match?(%Update{message: msg} = _upd, _context) do
    cond do
      msg && msg.from && msg.text ->
        msg.text && check_command(msg.text, @command)

      msg && msg.from && msg.users_shared ->
        State.check(msg.from.id, :add_admins)

      true ->
        false
    end
  end

  def handle(%Update{message: msg}, context) do
    cond do
      msg.text ->
        u = Elprimo.User.by_telegram_id(msg.from.id)
        send_button(u)
        State.update(u.telegram, :add_admins)
        {:done, context}

      msg.users_shared ->
        for uid <- msg.users_shared.user_ids do
          Logger.info(uid)
          Elprimo.User.add_admin("", uid)
        end

        Telegex.send_message(
          msg.from.id,
          "Добавили!",
          reply_markup: Elprimo.Handlers.Start.keyboard()
        )

        {:done, context}
    end
  end

  defp send_button(%Elprimo.User{} = u) do
    criteria = %KeyboardButtonRequestUsers{
      request_id: u.id,
      user_is_bot: false,
      max_quantity: 10
    }

    kb = %ReplyKeyboardMarkup{
      keyboard: [
        [%KeyboardButton{text: "Выбрать", request_users: criteria}]
      ]
    }

    Telegex.send_message(
      u.telegram,
      "Выберите людей, которые вы хотите добавить как админы. Нажмите кнопку \"Выбрать\"",
      reply_markup: kb
    )
  end
end

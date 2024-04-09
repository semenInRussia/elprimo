defmodule Elprimo.Handlers.Cancel do
  @moduledoc """
  Handle the /cancel command which must cancel the previous commands
  """
  @command "cancel"

  use Telegex.Chain

  import Elprimo.Utils

  alias Telegex.Type.Update
  alias Elprimo.State

  def label() do
    "Назад (отменить) ↩️"
  end

  def match?(%Update{message: msg}, _c) do
    msg && msg.text && msg.from && (check_command(msg.text, @command) || msg.text == label())
  end

  def handle(%Update{message: msg}, context) do
    State.update(msg.from.id, :none)
    Telegex.send_message(msg.from.id, "Предыдущая операция отменена! 🔙")
    {:done, context}
  end
end

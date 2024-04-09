defmodule Elprimo.Handlers.ForAll do
  @moduledoc """
  Handle an user query to resend the message to ALL admins.
  """

  use Telegex.Chain, :callback_query

  import Elprimo.Utils

  alias Telegex.Type.CallbackQuery

  @command "forall"

  def match?(%CallbackQuery{} = cb, _context) do
    cb.data && chop_1arg_command(cb.data, @command)
  end

  def handle(%CallbackQuery{} = cb, context) do
    msg_id = chop_1arg_command(cb.data, @command)
    msg = Elprimo.Message.by_id(msg_id)
    Elprimo.Message.send_to_admins(msg)
    {:done, context}
  end
end

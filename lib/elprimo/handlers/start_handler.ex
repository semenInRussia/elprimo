defmodule Elprimo.Handlers.StartHandler do
  use Telegex.Chain, :message
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
  def handle(%Message{} = msg, context) do
    Logger.warning(msg)
    txt = "Hi bro"
    Telegex.send_message(msg.chat.id, txt)
    {:done, context}
  end
end

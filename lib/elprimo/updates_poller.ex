defmodule Elprimo.UpdatesPoller do
  @moduledoc """
  Handle income from users updates.

  NOTE: that exists 2 ways to handle queries that income to the bot:

  1. Updates Poller (which are implemented in this file): Idea is to
     every 1sec (for example) check the list of income events and
     handle them then

  2. Web Hooks (which aren't implemented when I write this moduledoc)
     Idea is that when user do anything with bot, telegram will do some
     queries to certain URL with some information and this information
     bot handles

  the second is more optimal, but in that case we need to the server!
  """

  use Telegex.GenPoller

  def on_boot do
    %Telegex.Polling.Config{}
  end

  @impl true
  def on_update(update) do
    Elprimo.ChainHandler.call(update, %{})
  end
end

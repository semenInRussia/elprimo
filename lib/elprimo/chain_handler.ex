defmodule Elprimo.ChainHandler do
  @moduledoc """
  The place where I join all handlers of income Telegram messages and
  all updates.

  Each of handlers take a message/update and do anything with it.
  """

  use Telegex.Chain.Handler

  pipeline([
    Elprimo.Handlers.StartHandler,
    Elprimo.Handlers.QuestionHandler,
    Elprimo.Handlers.AnswHandler,
    Elprimo.Handlers.MsgHandler
  ])
end

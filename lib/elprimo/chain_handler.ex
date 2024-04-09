defmodule Elprimo.ChainHandler do
  @moduledoc """
  The place where I join all handlers of income Telegram messages and
  all updates.

  Each of handlers take a message/update and do anything with it.
  """

  use Telegex.Chain.Handler

  pipeline([
    Elprimo.Handlers.Start,
    Elprimo.Handlers.Cancel,
    Elprimo.Handlers.InlineQueries,
    Elprimo.Handlers.Query,
    Elprimo.Handlers.Question,
    Elprimo.Handlers.Answ,
    Elprimo.Handlers.Msg,
    Elprimo.Handlers.ForAll,
    Elprimo.Handlers.AddAdmins
  ])
end

defmodule Elprimo.ChainHandler do
  @moduledoc """
  The place where I join all handlers of income messages.

  Every handler take a message and do anything with it.
  """

  use Telegex.Chain.Handler

  pipeline([
    Elprimo.Handlers.StartHandler,
    Elprimo.Handlers.QuestionHandler,
    Elprimo.Handlers.AnswHandler
  ])
end

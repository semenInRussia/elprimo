defmodule Elprimo.Handlers.InlineQueriesHandler do
  @moduledoc """
  Handle income queries to inline queries.  Goal is provide auto
  completion for Doctype name.
  """
  alias Telegex.Type.InlineQueryResultArticle
  alias Telegex.Type.InputTextMessageContent

  use Telegex.Chain, :inline_query

  @impl Telegex.Chain
  def match?(_q, _c), do: true

  @impl Telegex.Chain
  def handle(q, context) do
    res =
      for d <- Elprimo.Doctype.all() do
        %InlineQueryResultArticle{
          type: "article",
          id: Integer.to_string(d.id),
          title: d.name,
          description: d.description,
          input_message_content: %InputTextMessageContent{
            message_text: d.name
          }
        }
      end

    Telegex.answer_inline_query(q.id, res)
    {:done, context}
  end
end

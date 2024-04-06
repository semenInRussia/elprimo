defmodule Elprimo.Utils do
  @moduledoc """
  Just some functions which I think should be inside standard Elixir
  library.
  """

  def now() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end

  @doc """
  Return true if a given text of user message is a command call.

  NOTE: that an expected command should be a command name without
  slash
  """
  def check_command(text, expected) when not is_nil(text) do
    text
    |> String.trim()
    |> String.equivalent?("/" <> expected)
  end

  def check_command(_, _), do: false

  @doc """
  Accept the text of a Telegram message and expected command which expect
  an ID after the name.

  Return the ID after a command name if a given text is an expected
  call, otherwise return false.
  """
  def chop_1arg_command(text, command) when not is_nil(text) do
    with text <- String.trim(text),
         "/" <> ^command <> id <- text,
         {id, ""} <- Integer.parse(id) do
      id
    else
      _ -> false
    end
  end

  def chop_1arg_command(_, _), do: false
end

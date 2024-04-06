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

  def check_command(_, _) do
    false
  end
end

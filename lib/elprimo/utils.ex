defmodule Elprimo.Utils do
  @moduledoc """
  Just some functions which I think should be inside standard Elixir
  library.
  """

  def now() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end
end

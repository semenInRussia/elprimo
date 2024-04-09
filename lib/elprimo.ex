defmodule Elprimo do
  @moduledoc """
  A telegram bot for help to my school administration.

  A name is generated from two Russian words:
  ELectronaya PRIemnaya -> Elprimo (a hero from Brawl Stars)
  """

  def send_to_admins(txt, opts \\ []) do
    for u <- Elprimo.User.admins() do
      Task.async(Telegex, :send_message, [u.telegram, txt] ++ opts)
    end
    |> Task.await_many()
  end
end

defmodule Elprimo.User do
  @moduledoc """
  A schema for Elprimo.User for sync with Database.
  """

  use Ecto.Schema
  import Ecto.Query

  schema "user" do
    field(:username, :string, default: nil)
    field(:telegram, :integer)
    field(:admin, :boolean)
  end

  def by_telegram_id(id) do
    query = from(u in __MODULE__, where: u.telegram == ^id, select: u)
    Elprimo.Repo.one(query)
  end

  def by_id(id) do
    query = from(u in __MODULE__, where: u.id == ^id, select: u)
    Elprimo.Repo.one(query)
  end

  def admins() do
    query = from(u in __MODULE__, where: u.admin, select: u)
    Elprimo.Repo.all(query)
  end

  def from_tgx(%Telegex.Type.User{username: username, id: id}) do
    %__MODULE__{username: username, telegram: id, admin: false}
  end
end

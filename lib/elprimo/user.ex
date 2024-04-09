defmodule Elprimo.User do
  @moduledoc """
  A schema for Elprimo.User for sync with Database.
  """

  use Ecto.Schema
  import Ecto.Query

  @type t() :: %__MODULE__{username: String.t(), telegram: integer(), admin: boolean()}

  schema "user" do
    field(:username, :string, default: nil)
    field(:telegram, :integer)
    field(:admin, :boolean)
  end

  @spec by_telegram_id(integer()) :: t() | nil
  def by_telegram_id(id) do
    query = from(u in __MODULE__, where: u.telegram == ^id, select: u)
    Elprimo.Repo.one(query)
  end

  @spec by_id(integer()) :: t() | nil
  def by_id(id) do
    query = from(u in __MODULE__, where: u.id == ^id, select: u)
    Elprimo.Repo.one(query)
  end

  @spec admins() :: list(t())
  def admins() do
    query = from(u in __MODULE__, where: u.admin, select: u)
    Elprimo.Repo.all(query)
  end

  @spec from_tgx(%Telegex.Type.User{}) :: t() | nil
  def from_tgx(%Telegex.Type.User{username: username, id: id}) do
    %__MODULE__{username: username, telegram: id, admin: false}
  end

  def add_admin(username, telegram) do
    Elprimo.Repo.insert(%__MODULE__{username: username, telegram: telegram, admin: true})
  end
end

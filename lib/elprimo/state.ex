defmodule Elprimo.State do
  @moduledoc """
  When we create a bot, sometimes we need to save state across all
  Telegram sessions, here I implement it.

  If the bot have a big BIG BIIIGG amount of users, then we need to a
  thing which can handle queries even if 2 and more users are using
  bot now, so I use Agent for it.

  You can think that this is an asynchronous Finite State Machine
  https://en.wikipedia.org/wiki/Finite-state_machine
  """

  use Agent

  @type state() :: :none | :question | {:answer, integer()}

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  Get the current state of an user, accept the ID of a Telegram user.
  """
  def get(id) do
    Agent.get(__MODULE__, &Map.get(&1, id, :none))
  end

  @doc """
  Compare the current state of an user with expected state, accept the
  ID of a Telegram user.

  Return true if expected and actual states are equal
  """
  def check(id, exp) do
    __MODULE__.get(id) == exp
  end

  @doc """
  Change the state of an user, accept the ID of a Telegram user.
  """
  def update(id, x) do
    Agent.update(__MODULE__, &Map.put(&1, id, x))
  end
end

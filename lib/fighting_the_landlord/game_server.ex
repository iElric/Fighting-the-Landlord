defmodule FightingTheLandlord.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {FightingTheLandlord.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker
    }
    FightingTheLandlord.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = FightingTheLandlord.BackupAgent.get(name) || Game.new()
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end






end

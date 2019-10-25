defmodule FightingTheLandlord.GameServer do
  use GenServer
  alias FightingTheLandlord.Game
  alias FightingTheLandlord.BackupAgent

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

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def add_player(name, player_name) do
    GenServer.call(reg(name), {:add_player, name, player_name})
  end

  def call_landlord(name, player_id) do
    GenServer.call(reg(name), {:call_landlord, name, player_id})
  end

  def pass_landlord(name, player_id) do
    GenServer.call(reg(name), {:pass_landlord, name, player_id})
  end

  def play_cards(name, player_id, card_indexes) do
    GenServer.call(reg(name), {:play_cards, name, player_id, card_indexes})
  end

  def pass(name, player_id) do
    GenServer.call(reg(name), {:pass, name, player_id})
  end

  def start_new_round(name, winner_id) do
    GenServer.call(reg(name), {:start_new_round, name, winner_id})
  end

  # server side
  def init(game) do
    {:ok, game}
  end

  # use this to get the initial game_state
  # because the start_link was called in game_sup
  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end

  def handle_call({:add_player, name, player_name}, _from, game) do
    {game, index} = Game.add_player(game, player_name)
    # since we might change the game_state, update it in backup_agent
    BackupAgent.put(name, game)
    {:reply, {game, index}, game}
  end

  def handle_call({:call_landlord, name, player_id}, _from, game) do
    new_game = Game.call_landlord(game, player_id)
    if is_nil(new_game) do
      # this call is illegal
      # return old game_state
      {:reply, game, game}
    else
      BackupAgent.put(name, new_game)
      {:reply, new_game, new_game}
    end
  end

  def handle_call({:pass_landlord, name, player_id}, _from, game) do
    new_game = Game.pass_landlord(game, player_id)
    if is_nil(new_game) do
      {:reply, game, game}
    else
      BackupAgent.put(name, new_game)
      {:reply, new_game, new_game}
    end
  end

  def handle_call({:play_cards, name, player_id, card_indexes}, _from, game) do
    new_game = Game.play_cards(game, player_id, card_indexes)
    if is_nil(new_game) do
      # this play is illegal
      # return old game_state
      {:reply, game, game}
    else
      # update the game_state, return new game state
      BackupAgent.put(name, new_game)
      {:reply, new_game, new_game}
    end
  end

  def handle_call({:pass, name, player_id}, _from, game) do
    new_game = Game.pass(game, player_id)
    if is_nil(new_game) do
      # can't pass, return old game state
      {:reply, game, game}
    else
      # update the game_state, return new game state
      BackupAgent.put(name, new_game)
      {:reply, new_game, new_game}
    end
  end

  def handle_call({:start_new_round, name, winner_id}, _from, game) do
    game = Game.start_new_round(game, winner_id)
    BackupAgent.put(name, game)
    {:reply, game, game}
  end
end

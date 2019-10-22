defmodule FightingTheLandlordWeb.GamesChannel do
  use FightingTheLandlordWeb, :channel

  alias FightingTheLandlord.Game
  alias FightingTheLandlord.BackupAgent
  alias FightingTheLandlord.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game = GameServer.peek(name)
      %{"player_name" => player_name} = payload
      {game, player_id} = GameServer.add_player(game, player_name)
      socket = socket
               |> assign(:name, name)
               |> assign(:player_id, player_id)
      broadcast!(socket, "player_joined", game)
      if Game.has_enough_players?(game) do
        {:ok, %{"join" => name, "game" => Game.player_view(game, player_id)}, socket}
      else
        {:ok, %{"join" => name, "game" => nil}, socket}
      end
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("play_cards", %{"card_indexes" => card_indexes}, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.play_cards(name, player_id, card_indexes)
    broadcast!(socket, "player_played", game)
    {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
  end

  def handle_in("pass", _payload, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.pass(name, player_id)
    broadcast!(socket, "player_passed", game)
    {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
  end

  intercept ["player_joined", "player_played", "player_passed"]

  def handle_out("player_joined", game, socket) do
    player_id = socket.assigns[:player_id]
    if Game.has_enough_players?(game) do
      push(socket, "player_joined", %{"game" => Game.player_view(game, player_id)})
    else
      push(socket, "player_joined", %{"game" => nil})
    end
  end

  def handle_out("player_played", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "player_played", %{"game" => Game.player_view(game, player_id)})
  end

  def handle_out("player_passed", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "player_passed", %{"game" => Game.player_view(game, player_id)})
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end


end

defmodule FightingTheLandlordWeb.GamesChannel do
  use FightingTheLandlordWeb, :channel

  alias FightingTheLandlord.Game
  alias FightingTheLandlord.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      IO.inspect(name)
      GameServer.start(name)
      %{"player_name" => player_name} = payload
      IO.inspect(player_name)
      {game, player_id} = GameServer.add_player(name, player_name)
      IO.inspect(player_id)
      IO.inspect(game)
      socket = socket
               |> assign(:name, name)
               |> assign(:player_id, player_id)
      send(self(), :after_join)
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

  def handle_info(:after_join, socket) do
    name = socket.assigns[:name]
    game = GameServer.peek(name)
    broadcast!(socket, "player_joined", game)
    {:noreply, socket}
  end

  intercept ["player_joined", "player_played", "player_passed"]

  def handle_out("player_joined", game, socket) do
    player_id = socket.assigns[:player_id]
    if Game.has_enough_players?(game) do
      push(socket, "player_joined", %{"game" => Game.player_view(game, player_id)})
    else
      push(socket, "player_joined", %{"game" => nil})
    end
    {:noreply, socket}
  end

  def handle_out("player_played", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "player_played", %{"game" => Game.player_view(game, player_id)})
    {:noreply, socket}
  end

  def handle_out("player_passed", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "player_passed", %{"game" => Game.player_view(game, player_id)})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end


end

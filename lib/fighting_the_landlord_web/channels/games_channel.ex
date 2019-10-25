defmodule FightingTheLandlordWeb.GamesChannel do
  use FightingTheLandlordWeb, :channel

  alias FightingTheLandlord.Game
  alias FightingTheLandlord.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      %{"player_name" => player_name} = payload
      {game, player_id} = GameServer.add_player(name, player_name)
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

  # only the winner can start a new game
  def handle_in("start_new_round", _payload, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.peek(name)
    winner_id = Game.who_wins(game)
    if is_nil(winner_id) or winner_id !== player_id do
      # if no winner or the caller is not the winner, return old game state
      # no need to broadcast
      {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
    else
      game = GameServer.start_new_round(name, winner_id)
      broadcast!(socket, "new_round", game)
      {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
    end
  end

  def handle_in("call_landlord", _payload, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.call_landlord(name, player_id)
    broadcast!(socket, "landlord_called", game)
    {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
  end

  def handle_in("pass_landlord", _payload, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.pass_landlord(name, player_id)
    broadcast!(socket, "landlord_passed", game)
    {:reply, {:ok, %{"game" => Game.player_view(game, player_id)}}, socket}
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

  def handle_in("who_wins", _payload, socket) do
    name = socket.assigns[:name]
    player_id = socket.assigns[:player_id]
    game = GameServer.peek(name)
    winner_id = Game.who_wins(game)
    if is_nil(winner_id) do
      {:reply, {:ok, %{"winner" => false}}, socket}
    else
      {:reply, {:ok, %{"winner" => true}}, socket}
    end
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    name = socket.assigns[:name]
    game = GameServer.peek(name)
    broadcast!(socket, "player_joined", game)
    {:noreply, socket}
  end

  intercept ["player_joined", "player_played", "player_passed", "new_round", "landlord_called", "landlord_passed"]

  def handle_out("player_joined", game, socket) do
    player_id = socket.assigns[:player_id]
    if Game.has_enough_players?(game) do
      push(socket, "player_joined", %{"game" => Game.player_view(game, player_id)})
    else
      push(socket, "player_joined", %{"game" => nil})
    end
    {:noreply, socket}
  end

  def handle_out("landlord_called", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "landlord_called", %{"game" => Game.player_view(game, player_id)})
    {:noreply, socket}
  end

  def handle_out("landlord_passed", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "landlord_passed", %{"game" => Game.player_view(game, player_id)})
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

  def handle_out("new_round", game, socket) do
    player_id = socket.assigns[:player_id]
    push(socket, "player_passed", %{"game" => Game.player_view(game, player_id)})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end


end

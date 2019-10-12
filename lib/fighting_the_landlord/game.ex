defmodule FightingTheLandlord.Game do
  alias FightingTheLandlord.Poker

  @base_point 5

  def new(number_of_games) do
    # new a game state
    %{
      remaining_games: number_of_games,
      previous_winner: nil,
      # indicate current game phase: 1. call_landlord 2. card_play
      phase: :call_landlord,
      # playerid
      landlord: nil,
      # playerid
      whose_turn: nil,
      # in phase call_landlord, the hands is list of length 4, the first three are players' hands, the fourth is 3 left overs cards
      # in phase card_play, the hands is list of length 3, all of them are players'hands
      # the indexes corresponds to playerid
      hands: Poker.deal_cards,
      points: [0, 0, 0],
      bomb_number: 0,
      # the first element in this tuple indicate the playerid (0, 1, 2), second is the hands played by that player
      previous_player: {nil, nil}
    }
  end

  def call_landlord(player_id, game_state) do
    %{hands: game_hands} = game_state
    landlord_hands = Poker.sort(Enum.at(game_hands, player_id) ++ Enum.at(game_hands, 3))
    game_hands = Enum.at
    game_state |> Map.put(:landlord, player_id) |> Map.put(:phase, :card_play) |> Map.put(:whose_turn, player_id) |> Map.put()
  end

  @doc """
  Return winner id if the winner exist, return nil otherwise
  """
  def who_wins(game_state) do
    %{phase: game_phase, hands: game_hands} = game_state
    if game_phase === :card_play do
      [{winner_id, _}] = game_hands |> Enum.with_index |> Enum.filter(fn({_, hand}) -> hand.length === 0 end)
      winner_id
    end
  end

  def play_cards(player_id, game_state) do
    if (player_id === game_state)

  end




end

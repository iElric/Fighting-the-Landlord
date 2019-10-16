defmodule FightingTheLandlord.Game do
  alias FightingTheLandlord.Poker

  @base_point 5

  defguardp guard_player_id(player_id) when player_id >= 0 and player_id <= 2

  def new(number_of_games) when number_of_games > 0 do
    # new a game state
    %{
      # often we have several round of games, at the end of these games, the one with highest points wins
      remaining_games: number_of_games,
      # the previous round winner get the priority to call landlord first
      previous_winner: nil,
      # indicate current game phase: 1. call_landlord 2. card_play
      phase: :call_landlord,
      # playerid
      landlord: nil,
      # playerid
      whose_turn: nil,
      # in phase call_landlord, the hands is list of length 4, the first three are players' hands, the fourth is 3 left overs card_index_list
      # in phase card_play, the hands is list of length 3, all of them are players'hands
      # the indexes corresponds to playerid
      hands: Poker.deal_cards(),
      points: [0, 0, 0],
      # each bomb in this round of game will result the base point * 2
      bomb_number: 0,
      # the first element in this tuple indicate the playerid (0, 1, 2), second is the hands played by that player
      previous_play: {nil, nil}
    }
  end

  def call_landlord(player_id, game_state)
      when guard_player_id(player_id) do
    %{hands: game_hands} = game_state
    landlord_hands = Poker.sort(Enum.at(game_hands, player_id) ++ Enum.at(game_hands, 3))
    game_hands = List.replace_at(game_hands, player_id, landlord_hands)

    game_state
    # specify the landlord
    |> Map.put(:landlord, player_id)
    # update phase
    |> Map.put(:phase, :card_play)
    # landlord start first
    |> Map.put(:whose_turn, player_id)
    # update landlord hands
    |> Map.put(:hands, game_hands)
  end

  @doc """
  Return winner id if the winner exist, return nil otherwise
  """
  # TODO: refactor this
  def who_wins(game_state) do
    %{phase: game_phase, hands: game_hands} = game_state

    if game_phase === :card_play do
      [{winner_id, _}] =
        game_hands
        |> Enum.with_index()
        |> Enum.filter(fn {_, hand} -> hand.length === 0 end)

      winner_id
    end
  end

  defp calculate_score(game_state) do
    %{
      landlord_id
    }
    landlord_id = game_state.landlord
    winner_id = game_state.previous_winner
    if landlord_id === winner_id do

    end
  end

  def play_cards_helper(game_state, player_id, cards) do
    current_hand = Enum.at(game_state.hands, player_id)
    current_hand = current_hand -- cards
    updated_hands = List.replace_at(game_state.hands, player_id, current_hand)
    game_state
    |> Map.put(:previous_play, {player_id, cards})
    |> Map.put(:hands, updated_hands)
    if length(current_hand) === 0 and game_state.remaining_games === 1 do
      game_state
      |> Map.put(:remainning_game, 0)
      |> Map.put(:previous_winner, player_id)

    else
      if length(current_hand) === 0 do
        new_remaining_game = game_state.remainig_game - 1
        new_previous_winner = player_id
        new_points = calculate_score()
        new_game_state = new(new_remaining_game)
        new_remaining_game
        |> Map.put(:previous_winner, new_previous_winner)
        |> Map.put(:points, new_points)
      else
        game_state
        |> Map.put(:whose_turn, rem(game_state.whose_turn + 1, 3))
      end
    end
  end

  def play_cards(game_state, player_id, card_indexes)
      when guard_player_id(player_id) do
    if game_state[:phase] === :card_play and game_state[:whose_turn] === player_id do
      %{hands: game_hands, previous_play: game_previous_play} = game_state
      hand = Enum.at(game_hands, player_id)
      cards = retrieve_cards(hand, card_indexes, [])
      category = Poker.category_of_hands(cards)
      {game_previous_player, game_previous_cards} = game_previous_play

      if !is_nil(category) do
        if player_id === game_previous_player do
          game_previous_play = {player_id, cards}
        else
          {cur_type, cur_weight} = category
          {prev_type, prev_weight} = Poker.category_of_hands(game_previous_cards)

          if Poker.is_first_beat_second?({cur_type, cur_weight}, {prev_type, prev_weight}) do
            hand = hand -- cards

            if length(hand) === 0 do
              game_remaining_games = game_state[:remaining_games]

              if game_remaining_games === 1 do
                game_state
                |> Map.put(:remaining_games, game_remaining_games - 1)
                |> Map.put(:preivous_winner, player_id)
                |> Map.put(:hands, List.replace_at(game_hands, player_id, hand))
              end
            end
          end
        end
      end
    end
  end

  defp retrieve_cards(_, [], acc) do
    Enum.reverse(acc)
  end

  defp retrieve_cards(hands, card_indexes, acc) do
    [head1 | tail1] = hands
    [head2 | tail2] = card_indexes
    {index, card} = head1

    if index === head2 do
      retrieve_cards(tail1, tail2, [card | acc])
    else
      retrieve_cards(tail1, card_indexes, acc)
    end
  end
end

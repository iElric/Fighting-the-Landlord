defmodule FightingTheLandlord.Poker do

  # return a new deck with 54 cards shuffled
  def new do
    for weight <- weights(), suit <- suits() do
      {weight, suit}
    end ++ [{50, :little_joker}, {100, :big_joker}]
    |> Enum.shuffle
  end

  # the weights represent the weight of the card, "3" to "10" have weights from 3 to 10
  defp weights do
    Enum.to_list(3..15)
  end

  defp suits do
    [:hearts, :diamonds, :clubs, :spades]
  end


end
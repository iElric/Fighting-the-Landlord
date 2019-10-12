defmodule FightingTheLandlord.Poker do
  @doc """
  Create a new suit of 54 cards deck, shuffle it and return. Deck is a list of tuples.
  Each card is a tuple {weight, suit}.
  The weights represent the weight of the card, "3" to "10" have weights from 3 to 10.
  "11" -> "J"
  "12" -> "Q"
  "13" -> "K"
  "14" -> "A"
  "15" -> "2"
  """
  def new do
    # the black and white joker is the littele joker which has weight of 50
    # the red joker is the big joker which has weight of 100.
    (for weight <- weights(), suit <- suits() do
       {weight, suit}
     end ++ [{50, :little_joker}, {100, :big_joker}])
    |> Enum.shuffle()
  end

  defp weights do
    Enum.to_list(3..15)
  end

  defp suits do
    [:hearts, :diamonds, :clubs, :spades]
  end

  @doc """
  Sort a list of cards by value in descending order.
  """
  def sort(cards) do
    cards |> Enum.sort() |> Enum.reverse()
  end

  # Asssume all the cards are sorted in descending order

  # when the length of the cards is 1
  def category_of_hands([{a, _}]) do
    {{:solo, nil}, a}
  end

  # when the length of the cards is 2
  def category_of_hands([{a, _}, {a, _}]) do
    {{:pair, nil}, a}
  end

  def category_of_hands([{a, :big_joker}, {b, :little_joker}]) do
    # for simplicity, make the "rocket" as "bomb"
    {{:bomb, nil}, a + b}
  end

  # when the length of the cards is 3
  def category_of_hands([{a, _}, {a, _}, {a, _}]) do
    {{:trio, nil}, a}
  end

  def category_of_hands([{a, :big_joker}, {b, :little_joker}, {_, _}]) do
    {{:four_with_solo, nil}, a + b}
  end

  # when the length of the cards is 4

  # the order of these functions matters! Do not change them without careful thoughts
  def category_of_hands([{a, _}, {a, _}, {a, _}, {a, _}]) do
    {{:bomb, nil}, a}
  end

  def category_of_hands([{a, _}, {a, _}, {a, _}, {_, _}]) do
    {{:trio_with_solo, nil}, a}
  end

  def category_of_hands([{_, _}, {a, _}, {a, _}, {a, _}]) do
    {{:trio_with_solo, nil}, a}
  end

  # the two joker can be played with two solos or one pair
  def category_of_hands([{a, :big_joker}, {b, :little_joker}, {_, _}, {_, _}]) do
    # two cases here: "jokers 5 4" or "jokers 33"
    {{:four_with_two, nil}, a + b}
  end

  # when the length of cards is 5

  def category_of_hands([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}]) do
    {{:trio_with_pair, nil}, a}
  end

  def category_of_hands([{b, _}, {b, _}, {a, _}, {a, _}, {a, _}]) do
    {{:trio_with_pair, nil}, a}
  end

  def category_of_hands([{a, _}, {a, _}, {a, _}, {a, _}, {_, _}]) do
    {{:four_with_solo, nil}, a}
  end

  def category_of_hands([{_, _}, {a, _}, {a, _}, {a, _}, {a, _}]) do
    {{:four_with_solo, nil}, a}
  end

  # always put the chains in the end to match
  # even though we did not use every variables, we are emphsizing that each weight should be distinct
  def category_of_hands([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}]) do
    # "chain" can't have "2"
    if a - e === 4 and a < 15 do
      {{:chain, 5}, a}
    end
  end

  # when the length of cards is 6
  def category_of_hands([{a, _}, {a, _}, {b, _}, {b, _}, {c, _}, {c, _}]) do
    if a - c === 2 and a < 15 do
      {{:pair_chain, 6}, a}
    end
  end

  def category_of_hands([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {b, _}]) do
    if a - b === 1 and a < 15 do
      {{:airplane, 6}, a}
    end
  end

  def category_of_hands([{_, _}, {_, _}, {a, _}, {a, _}, {a, _}, {a, _}]) do
    # two cases here: "3333 4 5" or "3333 44"
    {{:four_with_two, nil}, a}
  end

  def category_of_hands([{a, _}, {a, _}, {a, _}, {a, _}, {_, _}, {_, _}]) do
    # two cases here: "3333 4 5" or "3333 44"
    {{:four_with_two, nil}, a}
  end

  def category_of_hands([{_, _}, {a, _}, {a, _}, {a, _}, {a, _}, {_, _}]) do
    # two cases here: "3333 4 5" or "3333 44"
    {{:four_with_two, nil}, a}
  end

  def category_of_hands([{a, :big_joker}, {b, :little_joker}, {c, _}, {c, _}, {d, _}, {d, _}]) do
    {{:four_with_pairs, nil}, a + b}
  end

  def category_of_hands([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}, {f, _}]) do
    # "chain" can't have "2"
    if a - f === 5 and a < 15 do
      {{:chain, 6}, a}
    end
  end

  # when the length of cards is 7
  def category_of_hands([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}, {f, _}, {g, _}]) do
    # "chain" can't have "2"
    if a - g === 6 and a < 15 do
      {{:chain, 7}, a}
    end
  end

  # when the length of cards is 8
  def category_of_hands([{a, _}, {a, _}, {b, _}, {b, _}, {c, _}, {c, _}, {d, _}, {d, _}]) do
    if a - d === 3 and a < 15 do
      {{:pair_chain, 8}, a}
    end
  end

  # two consecutive bomb like "3333 4444" can be played as airplane
  def category_of_hands([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {b, _}, {_, _}, {_, _}]) do
    if a - b === 1 and a < 2 do
      {{:airplane_with_solos, 8}, a}
    end
  end

  def category_of_hands([{_, _}, {_, _}, {a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {b, _}]) do
    if a - b === 1 and a < 2 do
      {{:airplane_with_solos, 8}, a}
    end
  end

  def category_of_hands([{_, _}, {a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {b, _}, {_, _}]) do
    if a - b === 1 and a < 2 do
      {{:airplane_with_solos, 8}, a}
    end
  end

  def category_of_hands([{b, _}, {b, _}, {a, _}, {a, _}, {a, _}, {a, _}, {c, _}, {c, _}]) do
    {{:four_with_two_pairs, nil}, a}
  end

  def category_of_hands([{a, _}, {a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {c, _}, {c, _}]) do
    {{:four_with_two_pairs, nil}, a}
  end

  def category_of_hands([{b, _}, {b, _}, {c, _}, {c, _}, {a, _}, {a, _}, {a, _}, {a, _}]) do
    {{:four_with_two_pairs, nil}, a}
  end

  def category_of_hands([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}, {f, _}, {g, _}, {h, _}]) do
    # "chain" can't have "2"
    if a - h === 7 and a < 15 do
      {{:chain, 8}, a}
    end
  end

  # when the length of the cards is 9
  def category_of_hands([{a, _}, {a, _}, {a, _}, {b, _}, {b, _}, {b, _}, {c, _}, {c, _}, {c, _}]) do
    if a - c === 2 and a < 15 do
      {{:airplane, 9}, a}
    end
  end

  def category_of_hands([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}, {f, _}, {g, _}, {h, _}, {i, _}]) do
    # "chain" can't have "2"
    if a - i === 8 and a < 15 do
      {{:chain, 9}, a}
    end
  end

  # when the length of the cards is 10
  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:pair_chain, 10}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _}
      ]) do
    if a - b === 1 and a < 15 do
      {{:airplane_with_pairs, 10}, a}
    end
  end

  def category_of_hands([
        {c, _},
        {c, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {d, _},
        {d, _}
      ]) do
    if a - b === 1 and a < 15 do
      {{:airplane_with_pairs, 10}, a}
    end
  end

  def category_of_hands([
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _}
      ]) do
    if a - b === 1 and a < 15 do
      {{:airplane_with_pairs, 10}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {b, _},
        {c, _},
        {d, _},
        {e, _},
        {f, _},
        {g, _},
        {h, _},
        {i, _},
        {j, _}
      ]) do
    # "chain" can't have "2"
    if a - j === 9 and a < 15 do
      {{:chain, 10}, a}
    end
  end

  # when the length of the cards is 11
  def category_of_hands([
        {a, _},
        {b, _},
        {c, _},
        {d, _},
        {e, _},
        {f, _},
        {g, _},
        {h, _},
        {i, _},
        {j, _},
        {k, _}
      ]) do
    # "chain" can't have "2"
    if a - k === 10 and a < 15 do
      {{:chain, 11}, a}
    end
  end

  # when the length of the cards is 12
  def category_of_hands([
        {a, _},
        {b, _},
        {c, _},
        {d, _},
        {e, _},
        {f, _},
        {g, _},
        {h, _},
        {i, _},
        {j, _},
        {k, _},
        {l, _}
      ]) do
    # "chain" can't have "2"
    if a - l === 11 and a < 15 do
      {{:chain, 12}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _}
      ]) do
    if a - f === 5 and a < 15 do
      {{:pair_chain, 12}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane, 12}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {_, _},
        {_, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {_, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  # when length is 13, nothing illegal

  # when the length of the cards is 14
  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _}
      ]) do
    if a - g === 6 and a < 15 do
      {{:pair_chain, 14}, a}
    end
  end

  # when the length of the cards is 15
  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane, 15}, a}
    end
  end

  def category_of_hands([
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_pairs, 15}, a}
    end
  end

  def category_of_hands([
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {f, _},
        {f, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_pairs, 15}, a}
    end
  end

  def category_of_hands([
        {d, _},
        {d, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_pairs, 15}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {d, _},
        {d, _}
      ]) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_pairs, 15}, a}
    end
  end

  # when the length of the cards is 16
  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _},
        {h, _},
        {h, _}
      ]) do
    if a - h === 7 and a < 15 do
      {{:pair_chain, 16}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_solos, 16}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {_, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_solos, 16}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {_, _},
        {_, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_solos, 16}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_solos, 16}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {_, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_solos, 16}, a}
    end
  end

  # when length is 17, only illegal cards
  # when the length of the cards is 18
  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _},
        {h, _},
        {h, _},
        {i, _},
        {i, _}
      ]) do
    if a - i === 8 and a < 15 do
      {{:pair_chain, 18}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {f, _}
      ]) do
    if a - f === 5 and a < 15 do
      {{:airplane, 18}, a}
    end
  end

  # when length is 19, only illegal cards

  # when the length of the cards is 20
  def category_of_hands([
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _},
        {h, _},
        {h, _},
        {i, _},
        {i, _},
        {j, _},
        {j, _}
      ]) do
    if a - j === 9 and a < 15 do
      {{:pair_chain, 20}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {_, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {_, _},
        {_, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {_, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {_, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {e, _},
        {e, _},
        {e, _},
        {_, _},
        {_, _},
        {_, _},
        {_, _},
        {_, _}
      ]) do
    if a - e === 4 and a < 15 do
      {{:airplane_with_solos, 20}, a}
    end
  end

  def category_of_hands([
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _},
        {h, _},
        {h, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_pairs, 20}, a}
    end
  end

  def category_of_hands([
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {g, _},
        {g, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {h, _},
        {h, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_pairs, 20}, a}
    end
  end

  def category_of_hands([
        {e, _},
        {e, _},
        {f, _},
        {f, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {h, _},
        {h, _},
        {g, _},
        {g, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_pairs, 20}, a}
    end
  end

  def category_of_hands([
        {e, _},
        {e, _},
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {h, _},
        {h, _},
        {g, _},
        {g, _},
        {f, _},
        {f, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_pairs, 20}, a}
    end
  end

  def category_of_hands([
        {a, _},
        {a, _},
        {a, _},
        {b, _},
        {b, _},
        {b, _},
        {c, _},
        {c, _},
        {c, _},
        {d, _},
        {d, _},
        {d, _},
        {h, _},
        {h, _},
        {g, _},
        {g, _},
        {f, _},
        {f, _},
        {e, _},
        {e, _}
      ]) do
    if a - d === 3 and a < 15 do
      {{:airplane_with_pairs, 20}, a}
    end
  end
end

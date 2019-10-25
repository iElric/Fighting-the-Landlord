# Project Report
**Team: Yexin Wang, Hongjie LI**

## Introduction and Game Description

### Introduction
_Dou dizhu_ (aka “Fighting the Landlord”) is a card game in the genre of shedding and gambling which is one of the most well-known card games in China and suitable for all ages. Tencent, which is one of the largest tech companies in the world, has developed a popular app of this game. There even exist several national _Dou dizhu_ tournaments. _Dou dizhu_ is described as easy to learn but hard to master, requiring mathematical and strategic thinking as well as teamwork. _Dou dizhu_ has some variations,  the most popular one have 3 players with 1 deck of cards (with jokers). Less popular variations of the game do exist in China, such as four-player and five-player_dou dizhu_played with two packs of cards.

### Game Description
* A shuffled pack of 54 cards is dealt to three players. Each player is dealt 17 cards, with the last three leftover cards detained on the playing table, face down.
* All players first review and appraise their cards without showing their cards to the other players. Then, the player takes turns to bid for the landlord position. A Player can choose to bid or pass depends on their hands. Generally, the more confident a player is in the strength of one’s cards, the more likely the player will bid for landlord. If two or more players decide to claim the landlord title, the player who called landlord first gets the priority to become landlord. Normally, the previous round winner is the first to decide. The remaining two players form the peasants’ team. If none of three players bid, the deck will be reshuffled and dealt again(restart this round). The player who successfully becom the landlord will get three leftover cards.
* The landlord will be the first one to play the cards. In each player’s turn, he or she can choose to play or pass. The order is counterclockwise in regards to the player positions. The Player can only beat the prior hand using the same category with higher rank but not the others (More specific categories and ranks will be introduced in **Implementation of game rules** parts). If no other players beat this player’s prior hand, then this player gets the privilege to play again and he or she can play any legal categories of cards. To wrap up, if on player want to play cards, he or she either has to play cards in the same category with a higher rank or no other players beat his or her prior hand so he or she can play any legal cards.
* The landlord wins if he or she has no cards left. The peasant team wins if either of the peasants have no cards left. Often there will be a points system to evaluate players performance which means the winner get some points and the loser loses some points, they can choose to start a new round of game with previous points (rules of calculating points will be introduced in **Implementation of game rules** parts) saved.

## UI Design
In our project, we render every card as an image, and we use canvas to draw these images. There are 4 major components in the canvas. Besides, there are 2 types of view in our application. The first type is the player view, and the second type is the observer view.

## Join a table with Player Name
When visiting the home page, users have to enter a table name and player name to join the game. The table name is the identifier of a specific game room, and the player name is the identifier of that player. No duplicate names are allowed.

### Waiting for other players
The game won’t start unless there are more than 2 players, the page will show a message: “Waiting for players to join, game will start when more than 2 people join this table…”. The game will start automatically when there are enough players. A view will be given to the user depends on whether the user is a player or an observer. 

### Player View
There are 4 major components in a player view:
* Left component: It shows how many cards the left player still has (show back of those left cards), the game role of the player (landlord or peasant), the name of the player and the score of the player. If the left player is the player who played cards last time, the cards he/she played are shown next to their hands.
* Right component: everything is the same as left component.
* Bottom component: this is the view of the player himself or herself. Players are able to see the cards of their own. And when it is his or her turn to play cards, pass and play buttons will be shown. Every time the player clicks on a card, that card will pop up to indicate the card is selected. It can be clicked again if the player wants to unselect that card. Several cards can be selected at the same time.  The player can click the play button to play those selected cards. If the player doesn’t want to play any card, he or she can press the pass button to pass this turn. The played cards by the player himself or herself will locate at the top of his hands. At the end of a game, if this player is the winner, a restart button will be rendered for him or her. A new round will start if the winner click restart. 

### Observer view
The layout is the same as the player view (4 major components). The differences between an observer view from a player view is that an observer can see all players’ cards, and observers don't have any buttons. 

### Chat Room
In the center of the table, there is a text area to show all the messages sent by users in this table (technically all subscribers in this channel topic ). Every message contains a timestamp and the message itself. Users can type messages in the input area and hit send button to send a message. The input area will be automatically cleaned after send (although these types of cards game normally do not have a chat room since it is easy to cheat).

### Restart Button
The player who wins the game gets a restart button to start another round. All points the player loses or win this round will be kept to the new round.

## UI to Server Protocol
Our game has several interactions between clients and the server. Almost every action taken by one client should be broadcasted and intercepted. 

### Player Joined
Since we have to implement the mechanism that game only starts when users are more than two in that game room, we have to notify the other players that a new user has joined. For each user, the player has to join first and send the message to channel. In join, broadcast can’t be done, I solved this by using `send()` to self and broadcast in `handle_info()`. Channel now pushes the new game state to clients. This message has to be intercepted and customized in `handle_out()`since clients should have their views. What’s more, clients should have a `this.channel.on()`to listen for that “player_joined” message.

### Player Played 
When a player has just played some cards, a message will be sent to channel. Channel will pass those played cards to the server to check if the play is legal. Two situations here:
* If the play is legal, then the sever update the game state and channel will broadcast to others. This message has to be intercepted by `handle_out()`since client views have to be customized based on the roles of players.
* If the play is illegal, then the game state remains the same so no need to broadcast.
Same as player joined, a client should have a `this.channel.on()`to listen for that “player_played” message.

### Player Passed
Same logic as the player played.

### New Round
Who wins current round get a restart button to start a new round. Since the game state will change, this winner has to send message to channel, a channel then ask server to give a new game state with previous points preserved and broadcast to other clients. This message has to be intercepted by `handle_out()`since client_view has to be customized based on the roles of users. 
Client should have a `this.channel.on()`to listen for that “new_round” message to accept the new game state.

### New message
To implement a chat room, the clients have to send their messages to channel, channel then broadcast these messages to every users who subscribed to this channel. This is the only message which doesn’t need to be intercepted since every user in this game room should see the same messages.
 Client should have a `this.channel.on()`to listen for that “new_msg” message and update their message containers.

To wrap up, if clients do some interactions with the server and other clients also need to get the changes,  then this update should be broadcasted. If this update is different for different players and observers, then this update should be intercepted and customized before sending to other clients.

## Data structures on Server

### Cards

```
defp weights do
  Enum.to_list(3..15)
end

defp suits do
  [:hearts, :diamonds, :clubs, :spades]
end

defp new do
   (for weight <- weights(), suit <- suits() do
     {weight, suit}
   end ++ [{50, :little_joker}, {100, :big_joker}])
  |> Enum.shuffle()
end


```

A Card is a tuple as `{weight, suit}`. A deck of cards is a list of 54 tuples. Unlike the Poker, “2” has the highest weight (rank) in solo cards except for jokers. Please refer to the table below:

| Card            | Weght |
| --------------- | ----- |
| "3"             | 3     |
| "4"             | 4     |
| "5"             | 5     |
| "6"             | 6     |
| "7"             | 7     |
| "8"             | 8     |
| "9"             | 9     |
| "10"            | 10    |
| "J"             | 11    |
| "Q"             | 12    |
| "K"             | 13    |
| "A"             | 14    |
| "2"             | 15    |
| "B&W Joker"     | 50    |
| "Colored Joker" | 100   |

### Game State

```
%{
  phase: :call_landlord,
  landlord: nil,
  whose_turn: Enum.random(0..2),
  hands: Poker.deal_cards(),
  players: [],
  points: [0, 0, 0],
  bomb_number: 0,
  previous_play: {nil, nil}
}

```
  
* phase: phase indicates the current phase of the game. `:call_landlord` means the players are biding for landlord position.  `:card_play` means they have started to play cards.
* landlord: indicates who is the landlord. It should be an integer value as player id in 0…2, since there are only three players.
* hands: hands is a list of lists. It stores players’ current hands. This list is assembled by three list of card tuples because there are only three players have hands.
* players: players is a list of strings which stores all the players’ name (includes observers who can only watch players play).
* points: points is a list of 3 integers. We use this to measure players’ performance (rules of calculate points will be introduced in **Implementation of game rules** parts). 
* bomb_number: integer, used to count how many bombs played in this game. The more bombs have been played in this game, the higher the base point (each bomb in this round of game will result in the base point * 2) is.
* previous_play: the first element in this tuple indicate the player id (0, 1, 2), second is the hands played by that player.

### Client View

This is just one client view to demonstrate: 
```
%{
  phase: :card_play,
  landlord: relative_position(game_landlord, player_id),
  left: %{
    name: Enum.at(game_players, rem(player_id + 2, 3)),
    points: Enum.at(game_points, rem(player_id + 2, 3)),
    cards: length(Enum.at(game_hands, rem(player_id + 2, 3)))
  },
  right: %{
    name: Enum.at(game_players, rem(player_id + 1, 3)),
    points: Enum.at(game_points, rem(player_id + 1, 3)),
    cards: length(Enum.at(game_hands, rem(player_id + 1, 3)))
  },
  self: %{
    name: Enum.at(game_players, player_id),
    points: Enum.at(game_points, player_id),
    cards: Enum.at(game_hands, player_id) |> Poker.card_string()
  },
  active: game_whose_turn === player_id,
  previous_play: %{
    position: relative_position(game_previous_player, player_id),
    cards: game_previous_played_cards |> Poker.card_string()
  }
}
```

The client view is tricky since in this game each player should only see their own hands and the observers should be able to see all three players’ hands, which means client view should be customized based on player id. However, there are some common features shared by different players. When three players sitting beside a table, from one player’s point of view, other players are just a player to his or her left and a player to his or her right.  After calculating the relative position for one player,  we can abstract a common client view for these players.

* phase: indicate the current game phase.
* landlord: `:self` means landlord is the player himself or herself, `:left` means the landlord is to this player’s left, `:right` means the landlord is to this player’s right.
* left, self, right: these three maps have identical structures, which indicate some properties to these players. Name is the player’s name, point is the current point of that player. Cards are the current hand of the player. Notice if the client view is for players, then the left and right map’s cards should be integer numbers to show how many cards left in left or right player, self map’s cards should be list of cards. If the client view is for observers, all three players’ hands should be passed as list of cards.
* active: boolean value to indicate whether this player can take some actions.
* previous_play: show the previously played player and his or her previous cards, because front end needs to render these so that players know who played and what cards he or she has just played. 

## Implementation of game rules

### Legal Categories and Comparisons

When it is the player's turn to play cards, the player has two choices. The first one is pass, which means the player doesn’t want to play any cards, or the player doesn’t have any legal category of cards to play respecting the game rules. The second one is to play, the player can only play cards that have a higher rank and the same category with the cards being played previously. Therefore, the core of this game is to determine card categories and do some comparisons. 

The legal categories of cards are shown as tables:
| Card Category       | Length | Description                                  | Example                                       |
| ------------------- | ------ | -------------------------------------------- | --------------------------------------------- |
| solo                | 1      | any sigle card                               | 3                                             |
| pair                | 2      | two equal rank cards                         | 3,3                                           |
| bomb                | 2      | two jokers                                   | two jokers                                    |
| trio                | 3      | three equal rank cards                       | 3,3,3                                         |
| four_with_solo      | 3      | jokers with solo                             | two jokers, 3                                 |
| bomb                | 4      | four equal rank cards                        | 3,3,3,3                                       |
| trio_with_solo      | 4      | three equal rank with solo                   | 3,3,3,4                                       |
| four_with_two       | 4      | jokers with two cards                        | two jokers,3,4                                |
| trio_with_pair      | 5      | three equal rank with pair                   | 3,3,3,4,4                                     |
| four_with_solo      | 5      | four equal rank cards with solo              | 3,3,3,3,4                                     |
| chain               | 5      | five consecutive rank cards(3 - 14)          | 3,4,5,6,7                                     |
| four_with_two       | 6      | four equal rank cards with two cards         | 3,3,3,3,4,5                                   |
| four_with_pairs     | 6      | four equal rank cards with one pair          | 3,3,3,3,4,4                                   |
| pair_chain          | 6      | three consecutive pairs(3 - 14)              | 3,3,4,4,5,5                                   |
| airplane            | 6      | two consecutive trios                        | 3,3,3,4,4,4                                   |
| chain               | 6      | six consecutive cards                        | 3,4,5,6,7,8                                   |
| chain               | 7      | seven consecutive cards                      | 3,4,5,6,7,8,9                                 |
| airplane_with_solos | 8      | two consectutive trios with two cards(3 -14) | 3,3,3,4,4,4,5,6                               |
| four_with_two_pairs | 8      | four same rank cards with two pairs          | 3,3,3,3,4,4,6,6                               |
| pair_chain          | 8      | four consecutive pairs(3 - 14)               | 3,3,4,4,5,5,6,6                               |
| chain               | 8      | eight consecutive cards(3 - 14)              | 3,4,5,6,7,8,9,10                              |
| airplane            | 9      | three consecutive trios                      | 3,3,3,4,4,4,5,5,5                             |
| chain               | 9      | nine consecutive cards(3 -14)                | 3,4,5,6,7,8,9,10,11                           |
| airplane_with_pairs | 10     | two consecutive trios with two pairs         | 3,3,3,4,4,4,5,5,6,6                           |
| pair_chain          | 10     | five consecutive pairs(3 -14)                | 3,3,4,4,5,5,6,6,7,7                           |
| chain               | 10     | ten consecutive cards(3 -14)                 | 3,4,5,6,7,8,9,10,11,12                        |
| chain               | 11     | eleven consecutive cards(3 -14)              | 3,4,5,6,7,8,9,10,11,12,13                     |
| airplane            | 12     | four consecutive trios                       | 3,3,3,4,4,4,5,5,5,6,6,6                       |
| airplane_with_solos | 12     | three consecutive trios with three cards     | 3,3,3,4,4,4,5,5,5,9,10,11                     |
| pair_chain          | 12     | six consective pairs                         | 3,3,4,4,5,5,6,6,7,7,8,8                       |
| chain               | 12     | twelve consecutive cards (3 -14)             | 3,4,5,6,7,8,9,10,11,12,13,14                  |
| pair_chain          | 14     | seven consecutive pairs(3 -14)               | 3,3,4,4,5,5,6,6,7,7,8,8,9,9                   |
| airplane            | 15     | five consecutive trios                       | 3,3,3,4,4,4,5,5,5,6,6,6,7,7,7                 |
| airplane_with_pairs | 15     | three consecutive trios with three pairs     | 3,3,3,4,4,4,5,5,5,7,7,10,10,11,11             |
| airplane_with_solos | 16     | four consecutive trios with four cards       | 3,3,3,4,4,4,5,5,5,5,6,6,6,8,10,11,14          |
| airplane            | 18     | nine consecutive trios                       | 3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8           |
| pair_chain          | 18     | six consecutive pairs                        | 3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11       |
| airplane_with_solos | 20     | five consecutive trios with five cards       | 3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,9,9,10,11,12    |
| airplane_with_pairs | 20     | four consecutive trios with four pairs       | 3,3,3,4,4,4,5,5,5,6,6,6,7,7,9,9,12,12,13,13   |
| pair_chain          | 20     | ten consecutive pairs                        | 3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12 |

* Compare only the same Category. A player can only beat the prior hand using of the same Category but not the others. Note that this means that the ordering of the rows in the following table is not relevant to gameplay.
* Compare only the Chains with the same length. Beat the prior hand using the same number of cards is a basic doctrine which only the Rocket and the Bomb may violate. For example, although both 9-10-J-Q-K and 3-4-5-6-7-8-9 are Single Chains, 9-10-J-Q-K cannot beat 3-4-5-6-7-8-9, nor vice versa.
* Compare the rank in the Primal cards only. The Kicker's rank is irrelevant to the comparison unless a variation with 2+ decks is being played.
* Jokers and 2 are non-consecutive cards. Colored Joker, black-and-white Joker, and 2 cannot be used in any of the Primal cards of the Chains since they are not traditionally considered as the consecutive cards sequentially next to the Ace. Examples of illegal Chain: 2-3-4-5-6, 2-2-2-3-3-3 w/ A-A-7-7, K-A-2 + B&W Joker + Colored Joker.

### Pattern Matching to Determine Categories

We use pattern matching when we check the cards the player selected is legal to play or not. Even with powerful pattern matching, the process is still hard since the categories of this game are much more than the normal poker games. What’s more, in order to imitate the most popular Tencent version, we have to consider a lot of edge cases. For instance, “3333 4444” can be played as an airplane with solos (although player rarely does that since “3333” and “4444” are two bombs).   
For better matching, the cards should be sort by weights first. Even after sorting, mathematically, there are still several combinations possible for this specific category. For better understanding, an example of “airplane with solos” is given below. 

```
def category_of_hands(
        [
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
        ]
      ) do
    if a - d === 3 and a < 15 do
      {{:airplane, 12}, a}
    end
  end

  def category_of_hands(
        [
          {a, _},
          {a, _},
          {a, _},
          {_, _},
          {b, _},
          {b, _},
          {b, _},
          {_, _},
          {c, _},
          {c, _},
          {c, _},
          {_, _}
        ]
      ) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands(
        [
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
        ]
      ) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands(
        [
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
        ]
      ) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands(
        [
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
        ]
      ) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end

  def category_of_hands(
        [
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
        ]
      ) do
    if a - c === 2 and a < 15 do
      {{:airplane_with_solos, 12}, a}
    end
  end
```

This complexity is caused by the kicker cards since you can’t know if their weights are greater, equal to or smaller than the a, b and c. As a result, we have to find all the possible combinations. The order of matching matters too because Elixir always chooses the first match function. Therefore you have to carefully organize the order of these functions. 

### Play and Pass

**Play cards**
The player can play cards if:
1. There is no previous play (he or she is the first one to play in this game which means this player is the landlord), then this player can play any legal category of cards.
2. The previous player's id is the same as the this player, it means the other two players have passed, then this player can play any legal category of cards.
3. This player has the same category of cards as the previous played cards by  others yet with higher rank (or bomb since bomb can defeat any other types of cards).

**Pass**
The player can pass if:
1. This is not the first turn of this game which means landlord can’t pass his or her first turn (and he or she has no reason to do so either).
2. The previous played player is not this player. When other two passed this player’s cards, then it’s his privilege to play any category of legal cards.

Let's say there are 3 players a, b and c.  A is the landlord of this game. The first situation is when a game just started, a has to play first, he or she cannot pass that time. The cards she or he played are limited by category checking and value comparing rules of this game. The second situation is that, for instance, when b played some cards, then player c and player a both passed. when it’s player b's turn, he or she cannot pass but can play any legal cards. 

When a player played or passed in his turn, we will update the `whose_turn` in game state by `(current_player_id + 1) % 3`
except for this is the last turn (this player has played all his hands and win). 

### Calculate Score

The base point of a game is 5 which means if the landlord wins, he or she will get 10 points as a reward while the other two peasants will lose 5 points each.
For each bomb that occurred in this game, the base point will be multiplied by 2. For example,  if 3 bombs have been played in this game, then the landlord will get 80 points and each peasant will lose 40 points. This rule can make the game more exciting and affect the gameplay (you don’t want to play bombs without careful thinking).

## Challenges and Solutions

### Front End

* Challenge 1: Had problems in drawing pictures on canvas. Can not find the correct way to add images paths into the project.
* Solution 1: Checked the index page that Phoenix generated automatically (The one with "phoenix.png"), and tried the same way.
---
* Challenge 2: Had problems in adding event listeners on canvas.  Tried to add event listener to the context that I drew on canvas.
* Solution 2: Found the answer on stack overflow, the problem is that you can only add one event listener to canvas instead of the context on the canvas. However, by adding click event on canvas and get the position user clicked, it is easy to add a listener for that position.
---
* Challenge 3: Tried to understand `componentDidMount()` and `componentDidUpdate()`.
* Solution 3: Read React documents and checked some examples on line.
---
* Challenge 4: Separated the chat room from canvas. Adding chat room to canvas will cause the whole canvas to re-render when new messages come in.
* Solution 4:  Added chat room parts as react components instead of on canvas.


### Back End

* Challenge 1: There are lots of legal categories of cards. 
* Solution 1: Sort first, calculate combinations and using pattern matching to determine the categories.
---
* Challenge 2: How to pass the user name to the server?
* Solution 2: Store the username in payload and pass to channel when join. Add names to the game state and store the corresponding player id in socket.
---
* Challenge 3: How to use one react state for every client view?
* Solution: There are some common features shared by different players. When three players sitting beside a table, from one player’s point of view, other players are just a player to his or her left and a player to his or her right.  If we calculate the relative position to this player, then we can abstract a common client view for these players. 
---
* Challenge 4:  Customized view for different players and observers.
* Solution 4: Carefully read the phoenix channel document and using `handle_in()`for different messages (interactions),  `broadcast()` to notify other clients in Pubsub and `handle_out()` to intercept the messages and customized for that socket. 


## Reference

* [Wiki Doudizhu](https://en.wikipedia.org/wiki/Dou_dizhu)
  




 
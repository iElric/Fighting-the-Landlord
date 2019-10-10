# Project1 Proposal
Author: Yexin Wang, Hongjie Li

1. The game we are going to build named “Dou dizhu.” aka “Fighting the
Landlord”. It is one of the most well-known card games in China and suitable
for all ages. Tencent, which is one of the largest tech companies, has
developed a popular app of this game. There are even several national Dou
dizhu tournaments. The game is easy to play but requires some memorization,
mathematics, strategic thinking and teamwork to become a master.  You can have
3 players with 1 deck of cards (with jokers), or 4-5 players with 2 decks of
cards (with jokers). The game we are going to build is 3 players game with 1
deck of cards.

2.  The game is well specified. We are going to build the game
without changing its rules.
	* Players needs to take turns to play their own cards, but every player
	has to play cards which have higher ranks than the previous played cards.
	* The game is played by team. There are 3 players, one of them is the
	landlord (Dizhu), and the two other players are framers and form a team.
	If the landlord wins (the landlord has played all of his/her cards first),
	then the farmer team lose. If one of the farmers has no cards left, then
	the farmer team win. For more specific rules of the game, please go to
	https://en.wikipedia.org/wiki/Dou_dizhu.
	* For our application game, we are going to use points to implement the
	award and penalty. At the beginning of the game, every player has 0
	point. And the original point of one game is 10, the point of the game
	might change because of the user actions. (Any user play a “bomb” will
	double the point of the game).
	* After we have a winner(s), we need to distribute the points. Assume the
	current point of the game is 20. If the landlord wins,  each of the two
	players needs to give 10 points to the landlord, so after the first game,
	the landlord has 20 points, and each of the other players has -10 points.
	If the landlord loses, then the landlord needs to give 10 points to each
	player which the landlord will have -20 points and each of the player will
	have 10 points.
	* There are several categories of hands(from wiki):
		* Compare only the same Category. A player can only beat the prior
		hand using of the same Category but not the others. Note that this
		means that the ordering of the rows in the following table is not
		relevant to gameplay.
		* Compare only the Chains with the same length. Beat the prior hand
		using the same number of cards is a basic doctrine which only the
		Rocket and the Bomb may violate. For example, although both 9-10-J-Q-K
		and 3-4-5-6-7-8-9 are Single Chains, 9-10-J-Q-K cannot beat
		3-4-5-6-7-8-9, nor vice versa.
		* Compare the rank in the Primal cards only. The Kicker's rank is
		irrelevant to the comparison unless a variation with 2+ decks is
		being played.
		* Jokers and 2 are non-consecutive cards. Colored Joker,
		black-and-white Joker, and 2 cannot be used in any of the Primal cards
		of the Chains since they are not traditionally considered as the
		consecutive cards sequentially next to the Ace. Examples of illegal
		Chain: 2-3-4-5-6, 2-2-2-3-3-3 w/ A-A-7-7, K-A-2 + B&W Joker + Colored
		Joker.
		
	
3. About game functionalities:
	* A well-developed Dou dizhu allows users to show their cards publicly
	during the game, doing so will double the points of the game. (For
	example, if the original points of the game is 10, doing that will double
	the points to 20.) This rule doesn’t have much influence on the
	interactions with our server and players, thus we probably are not going
	to implement it in our game.
	* For the well-developed Dou dizhu, players need to call to be the
	landlord, and that probably would take 2 rounds. At the beginning of the
	game, the system would choose a player, and we call it player1. Player1
	has the highest priority to be the landlord. The first round the call
	landlord, if player1 and at least one of the other two players called to
	be landlord, then they need one more round of landlord call, which is
	double the points of the game. First player who double the points of the
	game would be the landlord. Player1 first claim if he_she wants to double
	the points. If nobody wants to double the points, then player1 would be
	the landlord. The landlord call process in our game would take one round,
	if player1 wants to be the landlord, then he_she would be the landlord,
	if player1 doesn’t, then the first player who called to be the landlord
	would be the landlord.

4. Possible challenges:
	* According to the Professor’s requirements, the game needs to be written
	with Elixir and Phoenix, even though we did some practices, this is the
	very first time for us to build a project from scratch instead of the
	starter code provided by professor . We think we might run into some
	issues of completing Channels, Genservers and so on.
	* One of the most complicate parts of this game is to implement
	the different categories of hands with ranks since the cards have many
	possible combinations.
	* Even if we simplify the landlord calling process, the process is still
	tricky because every player’s action is unpredictable, our server needs to
	make decisions based on user’s actions. What’s more, the user who played
	all of his/her cards first in last round has privilege to call landlord
	first.
	


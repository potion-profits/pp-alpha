extends Control

## Main game loop for blackjack minigame accessed from the blackjack tables

## Reference to the Deck used to manage cards
@onready var deck : = $Deck
## Container for spawning cards for the player
@onready var player_card_container : = $PlayerCardContainer
## Container for spawning cards for the dealer
@onready var dealer_card_container : = $DealerCardContainer
## Marker to indicate position for spawned player cards
@onready var player_pos : = $PlayerPos
## Marker to indicate position for spawned dealer cards
@onready var dealer_pos : = $DealerPos
## Button to perform a hit during the player's turn
@onready var hit : = $Hit
## Button to perform a stand during the player's turn
@onready var stand : = $Stand
## Reference to the Player to update chips after each round
@onready var player : = $Player
## UI container for handling player bets
@onready var bet_menu : = $BetMenu
## Label to display the amount of chips being bet
@onready var chip_amount : = $BetMenu/Bet/ChipAmount
## Label to display dealer score
@onready var dealer_score_lbl: Label = $DealerScore
## Label to display player score
@onready var player_score_lbl: Label = $PlayerScore
## UI container to display messages after each round
@onready var game_over_cont: Control = $GameOver
## Label to display outcome of each round
@onready var condition_lbl: Label = $GameOver/Condition
## Label to display resulting win or loss from each round
@onready var subtext_lbl: Label = $GameOver/Subtext
## Button to allow player to play again
@onready var play_again: Button = $GameOver/PlayAgain
## Button to exit blackjack
@onready var exit: Button = $GameOver/Exit
## Button added to make Ozcar happy since betting with zero is not intuitive
@onready var exit_bet: Button = $BetMenu/ExitBet
## Represents bet amount
var bet : int = 0
## Represents number of player cards for dynamic positioning
var player_count : int = 0
## Represents number of dealer cards for dynamic positioning
var dealer_count : int = 0
## Represents player score
var player_score : int = 0
## Represents dealer score
var dealer_score : int = 0
## Represents card values of cards in player hand
var player_hand : Array = []
## Represents card values of cards in dealer hand
var dealer_hand : Array = []

## States utilized in the state machine of the main game loop for blackjack
enum blackjack_state {
	PLAYER_BET,
	PLAYER_DEAL,
	DEALER_DEAL,
	PLAYER_TURN,
	DEALER_TURN,
	GAME_OVER,
	EXIT
}

## Represents the current state of the game
var current_state : blackjack_state = blackjack_state.PLAYER_BET

## Reference to Card scene for spawning cards
const CARD_SCENE = preload("res://scenes/casino/card.tscn")
## Map of card values to score
const CARD_VALUES = {"A" : 11, "1" : 1, "2" : 2, "3" : 3, "4" : 4, "5" : 5, "6" : 6,
	"7" : 7, "8" : 8, "9" : 9, "10" : 10, "J" : 10, "Q" : 10, "K" : 10}

signal bet_confirmed	## Indicates bet is confirmed by player
signal player_turn_over	## Indicates that the player has stood or busted
signal game_over_decision	## Idicates that the player is playing again or is exiting

func _ready() -> void:
	player.set_physics_process(false)
	play_blackjack()

## Main game loop handled by a state machine utilizing [enum blackjack_state]
func play_blackjack() -> void:
	while current_state != blackjack_state.EXIT:
		match current_state:
			blackjack_state.PLAYER_BET:
				await player_bet()
				if current_state == blackjack_state.EXIT:
					continue
				current_state = blackjack_state.PLAYER_DEAL
			blackjack_state.PLAYER_DEAL:
				# play card deal sound
				await spawn_player_card(deck.draw())
				# play card deal sound
				await spawn_player_card(deck.draw())
				current_state = blackjack_state.DEALER_DEAL
			blackjack_state.DEALER_DEAL:
				# play card deal sound
				await spawn_dealer_card(deck.draw())
				await spawn_dealer_card(deck.draw())
				if dealer_score == 21:
					declare_winner()
					continue
				current_state = blackjack_state.PLAYER_TURN
			blackjack_state.PLAYER_TURN:
				# need to check for split scenarios
				if player_score != 21:
					await player_turn()
				if current_state == blackjack_state.GAME_OVER:
					continue
				current_state = blackjack_state.DEALER_TURN
			blackjack_state.DEALER_TURN:
				while dealer_score < 18 and dealer_score < player_score:
					await dealer_draw()
				if current_state == blackjack_state.GAME_OVER:
					continue
				declare_winner()
			blackjack_state.GAME_OVER:
				await game_over_decision
				clear_screen()
				game_over_cont.visible = false
	exit_blackjack()

## Displays game over text to the player where:
## [br]    [param condition] = win/loss/push outcome
## [br]    [param subtext] = resulting win/loss from the outcome
func game_over(condition : String, subtext : String) -> void:
	current_state = blackjack_state.GAME_OVER
	game_over_cont.visible = true
	condition_lbl.text = condition
	subtext_lbl.text = subtext

## Clears the screen of the game over text and resets all properties for a new game
func clear_screen() -> void:
	for card in player_card_container.get_children():
		card.queue_free()
	for card in dealer_card_container.get_children():
		card.queue_free()
	bet = 0
	chip_amount.text = "0 Chips"
	player_count = 0
	dealer_count = 0
	player_score = 0
	dealer_score = 0
	player_hand = []
	dealer_hand = []
	player_score_lbl.visible = false
	dealer_score_lbl.visible = false

## Toggles the bet menu visibility
func toggle_bet_menu() -> void:
	bet_menu.visible = !bet_menu.visible

## Toggles the hit and stand buttons visibility
func toggle_hit_stand() -> void:
	hit.visible = !hit.visible
	stand.visible = !stand.visible

## Displays bet menu and awaits for player to confirm their bet
func player_bet() -> void:
	toggle_bet_menu()
	await self.bet_confirmed
	toggle_bet_menu()

## Displays the hit and stand buttons and awaits for player to stand or bust
func player_turn() -> void:
	toggle_hit_stand()
	await self.player_turn_over
	toggle_hit_stand()

## Draws a card for the dealer, updates the dealer score, and checks for a dealer bust
func dealer_draw() -> void:
	await spawn_dealer_card(deck.draw())
	score_dealer_hand()
	if dealer_score > 21:
		player.set_chips(2 * bet)
		game_over("YOU WIN", "Dealer busted. You won " + str(2 * bet) + " chips!")

## At the end of the dealer's and player's turns, declares who won the game
func declare_winner() -> void:
	if player_score > dealer_score:
		player.set_chips(2 * bet)
		game_over("YOU WIN", "Won " + str(2 * bet) + " chips!")
	elif player_score == dealer_score:
		player.set_chips(bet)
		game_over("PUSH", "Tie, you got your bet of " + str(bet) + " chips back.")
	else:
		game_over("YOU LOSE", "You lost " + str(bet) + " chips.")

## Spawns a card and adds it to the player's hand then updates player's score
func spawn_player_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = player_pos.position + Vector2(player_count*70, 0)
	card.set_card(card_name)
	player_card_container.add_child(card)
	player_hand.append(card_name.split("_")[0])
	player_count += 1
	score_player_hand()
	await get_tree().create_timer(0.5).timeout

## Spawns a card and adds it to the dealer's hand then updates the dealer's score
func spawn_dealer_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = dealer_pos.position + Vector2(dealer_count*70, 0)
	card.set_card(card_name)
	dealer_card_container.add_child(card)
	dealer_hand.append(card_name.split("_")[0])
	dealer_count += 1
	score_dealer_hand()
	await get_tree().create_timer(0.5).timeout

## Updates the player score label to reflect the player's current score. Includes logic
## to handle conversion of aces being scored as 11 to 1 when appropriate
func score_player_hand() -> void:
	player_score = 0
	for val : String in player_hand:
		player_score += CARD_VALUES[val]
	if player_score > 21:
		var i : int = player_hand.find("A")
		if i >= 0:
			player_hand[i] = "1"
			score_player_hand()
	player_score_lbl.visible = true
	player_score_lbl.text = "Player Score: " + str(player_score)

## Updates the dealer score label to reflect the dealer's current score. Includes logic
## to handle conversion of aces being scored as 11 to 1 when appropriate
func score_dealer_hand() -> void:
	dealer_score = 0
	for val : String in dealer_hand:
		dealer_score += CARD_VALUES[val]
	if dealer_score > 21:
		var i : int = dealer_hand.find("A")
		if i >= 0:
			dealer_hand[i] = "1"
			score_dealer_hand()
	dealer_score_lbl.visible = true
	dealer_score_lbl.text = "Dealer Score: " + str(dealer_score)

## Exits the blackjack scene and transitions to the casino floor using the SceneManager
func exit_blackjack() -> void:
	SceneManager.change_to("res://scenes/casino/casino_floor.tscn")

func _on_hit_pressed() -> void:
	await spawn_player_card(deck.draw())
	score_player_hand()
	if player_score > 21:
		game_over("YOU LOSE", "You busted, lost " + str(bet) + " chips")
		player_turn_over.emit()
	elif player_score == 21:
		player_turn_over.emit()

func _on_stand_pressed() -> void:
	player_turn_over.emit()

func _on_confirm_pressed() -> void:
	if bet > 0:
		player.set_chips(-bet)
		bet_confirmed.emit()

func _on_plus_chips_pressed() -> void:
	var current : int = player.get_chips()
	if Input.is_key_pressed(KEY_SHIFT):
		bet += 100
	else:
		bet += 10
	if bet >= current:
		bet = current
	chip_amount.text = str(bet) + " Chips"

func _on_minus_chips_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		bet -= 100
	else:
		bet -= 10
	if bet <= 0:
		bet = 0
	chip_amount.text = str(bet) + " Chips"

func _on_play_again_pressed() -> void:
	current_state = blackjack_state.PLAYER_BET
	game_over_decision.emit()

func _on_exit_pressed() -> void:
	current_state = blackjack_state.EXIT
	game_over_decision.emit()

func _on_exit_bet_pressed() -> void:
	current_state = blackjack_state.EXIT
	bet_confirmed.emit()

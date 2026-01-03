extends Control

@onready var deck : = $Deck
@onready var player_card_container : = $PlayerCardContainer
@onready var dealer_card_container : = $DealerCardContainer
@onready var player_pos : = $PlayerPos
@onready var dealer_pos : = $DealerPos
@onready var hit : = $Hit
@onready var stand : = $Stand
@onready var player : = $Player
@onready var bet_menu : = $BetMenu
@onready var chip_amount : = $BetMenu/Bet/ChipAmount
@onready var dealer_score_lbl: Label = $DealerScore
@onready var player_score_lbl: Label = $PlayerScore
@onready var game_over: Control = $GameOver
@onready var condition_lbl: Label = $GameOver/Condition
@onready var subtext_lbl: Label = $GameOver/Subtext
@onready var play_again: Button = $GameOver/PlayAgain
@onready var exit: Button = $GameOver/Exit
@onready var exit_bet: Button = $BetMenu/ExitBet
var bet : int = 0
var player_count : int = 0
var dealer_count : int = 0
var player_score : int = 0
var dealer_score : int = 0
var player_hand : Array = []
var dealer_hand : Array = []

enum blackjack_state {
	PLAYER_BET,
	PLAYER_DEAL,
	DEALER_DEAL,
	PLAYER_TURN,
	DEALER_TURN,
	GAME_OVER,
	EXIT
}

var current_state : blackjack_state = blackjack_state.PLAYER_BET

const CARD_SCENE = preload("res://scenes/casino/card.tscn")
const CARD_VALUES = {"A" : 11, "1" : 1, "2" : 2, "3" : 3, "4" : 4, "5" : 5, "6" : 6,
	"7" : 7, "8" : 8, "9" : 9, "10" : 10, "J" : 10, "Q" : 10, "K" : 10}

signal bet_confirmed
signal player_turn_over
signal game_over_decision

func _ready() -> void:
	player.set_physics_process(false)
	play_blackjack()

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
					await dealer_turn()
				if current_state == blackjack_state.GAME_OVER:
					continue
				declare_winner()
			blackjack_state.GAME_OVER:
				await game_over_decision
				clear_screen()
				game_over.visible = false
	exit_blackjack()

func reset(condition : String, subtext : String) -> void:
	current_state = blackjack_state.GAME_OVER
	game_over.visible = true
	condition_lbl.text = condition
	subtext_lbl.text = subtext

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

func toggle_bet_menu() -> void:
	bet_menu.visible = !bet_menu.visible

func toggle_hit_stand() -> void:
	hit.visible = !hit.visible
	stand.visible = !stand.visible
	
func player_bet() -> void:
	toggle_bet_menu()
	await self.bet_confirmed
	toggle_bet_menu()

func player_turn() -> void:
	toggle_hit_stand()
	await self.player_turn_over
	toggle_hit_stand()

func dealer_turn() -> void:
	await spawn_dealer_card(deck.draw())
	score_dealer_hand()
	if dealer_score > 21:
		player.set_chips(2 * bet)
		reset("YOU WIN", "Dealer busted. You won " + str(2 * bet) + " chips!")

func declare_winner() -> void:
	if player_score > dealer_score:
		player.set_chips(2 * bet)
		reset("YOU WIN", "Won " + str(2 * bet) + " chips!")
	elif player_score == dealer_score:
		player.set_chips(bet)
		reset("PUSH", "Tie, you got your bet of " + str(bet) + " chips back.")
	else:
		reset("YOU LOSE", "You lost " + str(bet) + " chips.")

func spawn_player_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = player_pos.position + Vector2(player_count*70, 0)
	card.set_card(card_name)
	player_card_container.add_child(card)
	player_hand.append(card_name.split("_")[0])
	player_count += 1
	score_player_hand()
	await get_tree().create_timer(0.5).timeout

func spawn_dealer_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = dealer_pos.position + Vector2(dealer_count*70, 0)
	card.set_card(card_name)
	dealer_card_container.add_child(card)
	dealer_hand.append(card_name.split("_")[0])
	dealer_count += 1
	score_dealer_hand()
	await get_tree().create_timer(0.5).timeout

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

func exit_blackjack() -> void:
	SceneManager.change_to("res://scenes/casino/casino_menu.tscn")

func _on_hit_pressed() -> void:
	await spawn_player_card(deck.draw())
	score_player_hand()
	if player_score > 21:
		reset("YOU LOSE", "You busted, lost " + str(bet) + " chips")
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
	if Input.is_action_pressed("sprint"):
		bet += 100
	else:
		bet += 10
	if bet >= current:
		bet = current
	chip_amount.text = str(bet) + " Chips"

func _on_minus_chips_pressed() -> void:
	if Input.is_action_pressed("sprint"):
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

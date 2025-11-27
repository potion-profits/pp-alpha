extends Node2D

@onready var deck : = $Deck
@onready var player_card_container : = $PlayerCardContainer
@onready var dealer_card_container : = $DealerCardContainer
@onready var player_pos : = $PlayerPos
@onready var dealer_pos : = $DealerPos
@onready var hit : = $Hit
@onready var stand : = $Stand
@onready var exit : = $Exit
@onready var player : = $Player
@onready var bet_menu : = $BetMenu
@onready var chip_amount : = $BetMenu/Bet/ChipAmount
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
	EXIT
}

var current_state : blackjack_state = blackjack_state.PLAYER_BET

const CARD_SCENE = preload("res://scenes/casino/card.tscn")
const CARD_VALUES = {"A" : 11, "1" : 1, "2" : 2, "3" : 3, "4" : 4, "5" : 5, "6" : 6,
	"7" : 7, "8" : 8, "9" : 9, "10" : 10, "J" : 10, "Q" : 10, "K" : 10}

signal bet_confirmed
signal player_turn_over

func _ready() -> void:
	player.set_physics_process(false)
	play_blackjack()

func play_blackjack() -> void:
	while current_state != blackjack_state.EXIT:
		print(current_state)
		match current_state:
			blackjack_state.PLAYER_BET:
				await player_bet()
				if bet == 0:
					current_state = blackjack_state.EXIT
					break
				current_state = blackjack_state.PLAYER_DEAL
			blackjack_state.PLAYER_DEAL:
				spawn_player_card(deck.draw())
				spawn_player_card(deck.draw())
				score_player_hand()
				current_state = blackjack_state.DEALER_DEAL
			blackjack_state.DEALER_DEAL:
				spawn_dealer_card(deck.draw())
				spawn_dealer_card(deck.draw())
				score_dealer_hand()
				if dealer_score == 21:
					print("Dealer scored 21, you lose")
					reset()
					continue
				current_state = blackjack_state.PLAYER_TURN
			blackjack_state.PLAYER_TURN:
				# need to check for split scenarios
				await player_turn()
				if current_state == blackjack_state.PLAYER_BET:
					continue
				current_state = blackjack_state.DEALER_TURN
			blackjack_state.DEALER_TURN:
				dealer_turn()
				if current_state == blackjack_state.PLAYER_BET:
					continue
				declare_winner()
				reset()
	_on_exit_pressed()

func reset() -> void:
	current_state = blackjack_state.PLAYER_BET
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
	while dealer_score < 18 and dealer_score < player_score:
		spawn_dealer_card(deck.draw())
		score_dealer_hand()
	if dealer_score > 21:
		print("Dealer BUSTED, you win! dealer score = ", dealer_score)
		player.set_chips(2 * bet)
		reset()

func declare_winner() -> void:
	if player_score > dealer_score:
		print("You win! score = ", player_score, "\ndealer score = ", dealer_score)
		player.set_chips(2 * bet)
	elif player_score == dealer_score:
		print("Push on tie!")
		player.set_chips(bet)
	else:
		print("You lose. score = ", player_score, "\ndealer score = ", dealer_score)

func spawn_player_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = player_pos.position + Vector2(player_count*70, 0)
	card.set_card(card_name)
	player_card_container.add_child(card)
	player_hand.append(card_name.split("_")[0])
	player_count += 1

func spawn_dealer_card(card_name: String) -> void:
	var card : = CARD_SCENE.instantiate()
	card.position = dealer_pos.position + Vector2(dealer_count*70, 0)
	card.set_card(card_name)
	dealer_card_container.add_child(card)
	dealer_hand.append(card_name.split("_")[0])
	dealer_count += 1

func score_player_hand() -> void:
	player_score = 0
	for val : String in player_hand:
		player_score += CARD_VALUES[val]
	if player_score > 21:
		var i : int = player_hand.find("A")
		if i >= 0:
			player_hand[i] = "1"
			score_player_hand()
	print("Current score: ", player_score)

func score_dealer_hand() -> void:
	dealer_score = 0
	for val : String in dealer_hand:
		dealer_score += CARD_VALUES[val]
	if dealer_score > 21:
		var i : int = dealer_hand.find("A")
		if i >= 0:
			dealer_hand[i] = "1"
			score_dealer_hand()
	print("Dealer score: ", dealer_score)

func _on_exit_pressed() -> void:
	var cs:String = get_tree().current_scene.name
	GameManager.save_scene_runtime_state(cs)
	await get_tree().process_frame
	GameManager.connect_scene_load_callback()
	get_tree().change_scene_to_file("res://scenes/casino/casino_menu.tscn")

func _on_hit_pressed() -> void:
	spawn_player_card(deck.draw())
	score_player_hand()
	if player_score > 21:
		print("You BUSTED, score = ", player_score)
		reset()
		player_turn_over.emit()

func _on_stand_pressed() -> void:
	player_turn_over.emit()

func _on_confirm_pressed() -> void:
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

extends Control

## Handles the main casino menu.
##
## This includes transitioning to town or blackjack table and currency exchange.
## @expiremental Likely to change given casino scene development.

@onready var v_box_container : = $MarginContainer/VBoxContainer ## Reference to main casino menu button container
@onready var v_box_container_2 : = $MarginContainer/VBoxContainer2 ## Reference to exchange menu container
@onready var coins : = $Coins	## Sprite reference for coins
@onready var num_coins : = $NumCoins	## Label reference for coin amount
@onready var num_chips : = $NumChips	## Label reference for chip amount
@onready var player : = $Player	## Reference to player
## Reference to label displaying exchange amount
@onready var num_coins_to_exchange : = $MarginContainer/VBoxContainer2/HBoxContainer/NumCoinsToExchange
var exchange_amount : int = 0	## Current amount of coins to exchange
@onready var chips: AnimatedSprite2D = $Chips	## Animated sprite reference for chips


func _ready() -> void:
	player.set_physics_process(false)
	coins.play("default")
	chips.play("default")
	update_coins_and_chips()
	update_exchange_label(exchange_amount)

## Visually updates the UI overlay to display the player's chips and coins
func update_coins_and_chips() -> void:
	num_coins.text = str(player.get_coins())
	num_chips.text = str(player.get_chips())

# goes to blackjack game
func _on_black_jack_pressed() -> void:
	SceneManager.change_to("res://scenes/casino/black_jack.tscn")

# goes to currency exchange menu
func _on_exchange_pressed() -> void:
	v_box_container.visible = false
	v_box_container_2.visible = true

# goes back to scene
func _on_casino_exit_pressed() -> void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

# goes back to main casino menu
func _on_cancel_exchange_pressed() -> void:
	v_box_container.visible = true
	v_box_container_2.visible = false

# handles increasing the coins to be exchanged
func _on_more_coins_pressed() -> void:
	var current : int = player.get_coins()
	if Input.is_action_pressed("dash"):
		exchange_amount += 100
	else:
		exchange_amount += 10
	if exchange_amount >= current:
		exchange_amount = current - (current % 10)
		# not enough coins label
	update_exchange_label(exchange_amount)

## Visually updates the coins to be exchanged
func update_exchange_label(new_amt : int) -> void:
	num_coins_to_exchange.text = str(new_amt) + " Coins"

# handles decreasing the coins to be exchanged
func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("dash"):
		exchange_amount -= 100
	else:
		exchange_amount -= 10
	if exchange_amount <= 0:
		exchange_amount = 0
	update_exchange_label(exchange_amount)

# handles the actual exchange of coins to chips
func _on_confirm_exchange_pressed() -> void:
	player.set_coins(-exchange_amount)
	player.set_chips(exchange_amount)
	update_coins_and_chips()
	exchange_amount = 0
	update_exchange_label(exchange_amount)

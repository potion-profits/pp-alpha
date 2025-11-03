extends Control

@onready var v_box_container : = $MarginContainer/VBoxContainer
@onready var v_box_container_2 : = $MarginContainer/VBoxContainer2
@onready var coins : = $Coins
@onready var num_coins : = $NumCoins
@onready var num_chips : = $NumChips
@onready var player : = $Player
@onready var num_coins_to_exchange : = $MarginContainer/VBoxContainer2/HBoxContainer/NumCoinsToExchange
var exchange_amount : int = 0
@onready var chips: AnimatedSprite2D = $Chips


func _ready() -> void:
	player.set_physics_process(false)
	coins.play("default")
	chips.play("default")
	update_coins_and_chips()
	update_exchange_label(exchange_amount)

func update_coins_and_chips() -> void:
	num_coins.text = str(player.get_coins())
	num_chips.text = str(player.get_chips())

func _on_black_jack_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/casino/black_jack.tscn")

func _on_exchange_pressed() -> void:
	v_box_container.visible = false
	v_box_container_2.visible = true

func _on_casino_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/playground/playground.tscn")

func _on_cancel_exchange_pressed() -> void:
	v_box_container.visible = true
	v_box_container_2.visible = false

func _on_more_coins_pressed() -> void:
	var current : int = player.get_coins()
	if Input.is_action_pressed("sprint"):
		exchange_amount += 100
	else:
		exchange_amount += 10
	if exchange_amount >= current:
		exchange_amount = current - (current % 10)
		# not enough coins label
	update_exchange_label(exchange_amount)

func update_exchange_label(new_amt : int) -> void:
	num_coins_to_exchange.text = str(new_amt) + " Coins"

func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		exchange_amount -= 100
	else:
		exchange_amount -= 10
	if exchange_amount <= 0:
		exchange_amount = 0
	update_exchange_label(exchange_amount)

func _on_confirm_exchange_pressed() -> void:
	player.set_coins(-exchange_amount)
	player.set_chips(exchange_amount)
	update_coins_and_chips()
	exchange_amount = 0
	update_exchange_label(exchange_amount)

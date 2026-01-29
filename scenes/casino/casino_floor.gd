extends Node2D

@onready var player: Player = $Player
@onready var exchange_bttn: Button = $Player/Camera2D/ExchangeBttn
@onready var exchange_container: VBoxContainer = $Player/Camera2D/ExchangeContainer
@onready var num_coins_to_exchange: Label = $Player/Camera2D/ExchangeContainer/HBoxContainer/NumCoinsToExchange
var exchange_amt : int = 0

func _ready() -> void:
	exchange_container.visible = false
	exchange_bttn.visible = true

func _on_exchange_bttn_pressed() -> void:
	exchange_container.visible = true
	exchange_bttn.visible = false

func _on_confirm_exchange_pressed() -> void:
	player.set_coins(-exchange_amt)
	player.set_chips(exchange_amt)
	exchange_amt = 0
	update_exchange_label(exchange_amt)

func _on_cancel_exchange_pressed() -> void:
	exchange_container.visible = false
	exchange_bttn.visible = true

func _on_less_coins_pressed() -> void:
	if Input.is_action_pressed("sprint"):
		exchange_amt -= 100
	else:
		exchange_amt -= 10
	if exchange_amt <= 0:
		exchange_amt = 0
	update_exchange_label(exchange_amt)

func _on_more_coins_pressed() -> void:
	var current : int = player.get_coins()
	if Input.is_action_pressed("sprint"):
		exchange_amt += 100
	else:
		exchange_amt += 10
	if exchange_amt >= current:
		exchange_amt = current - (current % 10)
		# not enough coins label
	update_exchange_label(exchange_amt)

func update_exchange_label(new_amt : int) -> void:
	num_coins_to_exchange.text = str(new_amt) + " Coins"

func _on_move_town_area_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town/town.tscn")

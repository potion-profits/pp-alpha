extends Control

@export var player: Player
@onready var player_coins: Label = $HBoxContainer/coin_amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_coins.call_deferred()
	player.update_coins.connect(update_coins)
	pass
	
func update_coins() -> void:
	player_coins.text = str(player.get_coins())

extends Control

## Handles displaying the player's coins

@export var player: Player	## Will hold a reference to the player once the scene tree is built
@onready var player_coins: Label = $HBoxContainer/coin_amount	## Label reference to the coin amount text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_coins.call_deferred()
	player.update_coins.connect(update_coins)
	
## Visually displays the player's current coins
func update_coins() -> void:
	player_coins.text = str(player.get_coins())

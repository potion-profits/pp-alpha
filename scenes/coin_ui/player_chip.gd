extends Control

@export var player: Player
@onready var player_chips: Label = $HBoxContainer/chip_amount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_chips.call_deferred()
	player.update_chips.connect(update_chips)
	
func update_chips() -> void:
	player_chips.text = str(player.get_chips())

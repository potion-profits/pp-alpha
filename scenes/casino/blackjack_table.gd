extends Entity

@onready var interactable : Area2D = $Interactable
@onready var table_sprite: Sprite2D = $TableSprite

const BLACKJACK_TOOLTIP: String = "Press E to Play Blackjack"

func _ready() -> void:	
	# Links interactable template to barrel specific method
	interactable.interact = _on_interact
	interactable.tooltip = BLACKJACK_TOOLTIP
	
	# Sets up entity info
	super._ready()

func _on_interact() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	if player:
		if player.chips == 0:
			# invalid chip amount to play blackjack
			return
		SceneManager.change_to("res://scenes/casino/black_jack.tscn")

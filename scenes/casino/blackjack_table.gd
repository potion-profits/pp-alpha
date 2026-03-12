extends Entity

@onready var interactable : Area2D = $Interactable
@onready var table_sprite: Sprite2D = $TableSprite

var player_in_area: Player
var BLACKJACK_TOOLTIP: String = "Press %s to Play Blackjack"

func _ready() -> void:	
	# Links interactable template to barrel specific method
	interactable.interact = _on_interact
	interactable.is_interactable = false
	
	# Sets up entity info
	super._ready()

func _on_interact() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	if player:
		if player.chips == 0:
			# invalid chip amount to play blackjack
			return
		SceneManager.change_to("res://scenes/casino/black_jack.tscn")


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = body
		set_process(true)


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = null
		set_process(false)
		
func _process(_delta: float) -> void:
	if player_in_area:
		if (player_in_area.chips > 0):
			interactable.set_tooltip_label(BLACKJACK_TOOLTIP)
			interactable.is_interactable = true
			return
	
	interactable.is_interactable = false

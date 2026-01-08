extends Entity

@onready var interactable : Area2D = $Interactable
@onready var table_sprite: Sprite2D = $TableSprite

func _ready() -> void:	
	# Links interactable template to barrel specific method
	interactable.interact = _on_interact
	
	# Sets up entity info
	super._ready()

func _on_interact() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	if player:
		if player.chips == 0:
			# invalid chip amount to play blackjack
			return
		var cs:String = get_tree().current_scene.name
		GameManager.save_scene_runtime_state(cs)
		await get_tree().process_frame
		GameManager.connect_scene_load_callback()
		get_tree().change_scene_to_file("res://scenes/casino/black_jack.tscn")

extends Entity

## The bed is an interactable entity that saves the game.

@onready var interactable : Area2D = $Interactable ## Reference to component used for interactions

func _ready() -> void:
	# Links interactable template to bed specific method
	interactable.interact = _on_interact
	
	# Sets up entity info
	super._ready()
	
	# Used to find out what scene to place in entity manager
	entity_code = "bed"

func _on_interact() -> void:
	GameManager.save_scene_runtime_state()
	GameManager.commit_to_storage()

## Scene transition entity for the casino exterior.
## On interact, transitions the player to the casino floor scene.
extends Entity

@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact
	super._ready()
	entity_code = "casino_ext"

## Transitions to the casino floor scene on interaction.
func _on_interact() -> void:
	SceneManager.change_to("res://scenes/casino/casino_floor.tscn")

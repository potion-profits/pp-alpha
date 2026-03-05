## Scene transition entity for the misc shop exterior.
## On interact, transitions the player to the town menu scene.
extends Entity

@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact
	super._ready()
	entity_code = "misc_shop_ext"

## Transitions to the town menu scene on interaction.
func _on_interact() -> void:
	SceneManager.change_to("res://scenes/supply_shop/supply_shop.tscn")

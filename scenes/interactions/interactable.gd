extends Area2D

## Used to dictate if an [Entity] is interactable.

@export var tooltip: String ="Press E to interact"
@export var is_interactable: bool = true

## Links the entity's interact function
var interact: Callable = func() -> void:
	pass

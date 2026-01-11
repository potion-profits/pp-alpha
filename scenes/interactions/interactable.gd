extends Area2D

## Used to dictate if an [Entity] is interactable.

@export var interact_name: String =""
@export var is_interactable: bool = true

## Links the entity's interact function
var interact: Callable = func() -> void:
	pass

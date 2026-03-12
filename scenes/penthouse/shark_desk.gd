extends StaticBody2D

@onready var interactable: Area2D = $Interactable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.tooltip = "Press E to talk"

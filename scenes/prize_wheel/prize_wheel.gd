extends Node2D

@onready var wheel: Sprite2D = $Wheel
@onready var is_spinning : bool = false
@onready var speed : float = 3
@onready var interactable : Node = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact

func _physics_process(delta: float) -> void:
	if is_spinning:
		wheel.rotate(speed * delta)
		if speed > 0:
			speed -= delta
		else:
			is_spinning = false

func _on_interact() -> void:
	speed = 3
	is_spinning = true

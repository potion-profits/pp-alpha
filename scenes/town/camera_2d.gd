extends Camera2D

@export var target: Node2D

func _process(_delta: float) -> void:
	if target:
		global_position = target.global_position + Vector2(0, -50)

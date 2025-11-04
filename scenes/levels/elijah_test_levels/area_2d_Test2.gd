extends Area2D

var entered: bool = false

func _on_body_entered(_body: Object) -> void:
	entered = true

func _on_body_exited(_body: Object) -> void:
	entered = false

# If player is near door, pressing "enter" will load a new scene
func _process(_delta: float) -> void:
	if entered == true:
		if Input.is_action_just_pressed("interact"):
			get_tree().change_scene_to_file("res://scenes/levels/elijah_test_levels/test_level.tscn")

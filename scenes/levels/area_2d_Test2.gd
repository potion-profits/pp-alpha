extends Area2D

var entered = false

func _on_body_entered(body: PhysicsBody2D):
	entered = true

func _on_body_exited(body: PhysicsBody2D):
	entered = false

# If player is near door, pressing "enter" will load a new scene
func _process(delta):
	if entered == true:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to_file("res://scenes/levels/test_level.tscn")

extends Area2D

var player_in_area = false

func _on_body_entered(body: PhysicsBody2D):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body: PhysicsBody2D):
	if body.name == "Player":
		player_in_area = false

# If player is near door, pressing "enter" will load a new scene
func _process(delta):
	if player_in_area == true:
		if Input.is_action_just_pressed("ui_accept"):
			get_tree().change_scene_to_file("res://scenes/levels/elijah_test_levels/test_level2.tscn")

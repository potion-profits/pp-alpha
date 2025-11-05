extends Node2D

func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))


func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/casino/casino_menu.tscn")
		


func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		pass
		#get_tree().call_deferred("change_scene_to_file", INSERT_STORAGE_ROOM_SCENE)

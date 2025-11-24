extends Node2D

@onready var frontroom_backdoor_dest_marker: Marker2D = $frontroom_backdoor_dest_marker
@onready var backroom_frontdoor_dest_marker: Marker2D = $backdoor_frontroom_dest_marker
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D

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
		body.global_position = backroom_frontdoor_dest_marker.global_position
		player_camera.limit_top -= 300
		player_camera.limit_bottom -= 350
		

func _on_move_front_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = frontroom_backdoor_dest_marker.global_position
		player_camera.limit_top += 300
		player_camera.limit_bottom += 350

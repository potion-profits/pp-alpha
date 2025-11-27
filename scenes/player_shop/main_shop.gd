extends Node2D
@onready var floor_map : Node2D = $AstarTilemap
@onready var frontroom_backdoor_dest_marker: Marker2D = $frontroom_backdoor_dest_marker
@onready var backroom_frontdoor_dest_marker: Marker2D = $backdoor_frontroom_dest_marker
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D
@onready var f_top_left: Marker2D = $FrontRoomEdges/TopLeft
@onready var f_bottom_right: Marker2D = $FrontRoomEdges/BottomRight
@onready var b_top_left: Marker2D = $BackRoomEdges/TopLeft
@onready var b_bottom_right: Marker2D = $BackRoomEdges/BottomRight

func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))


func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		var cs:String = get_tree().current_scene.name
		GameManager.save_scene_runtime_state(cs)
		await get_tree().process_frame
		get_tree().call_deferred("change_scene_to_file", "res://scenes/town_menu/town_menu.tscn")

func transition_camera(top_left: Marker2D, bottom_right: Marker2D) -> void:
	player_camera.limit_left = int(top_left.global_position.x)
	player_camera.limit_top = int(top_left.global_position.y)
	player_camera.limit_right = int(bottom_right.global_position.x)
	player_camera.limit_bottom = int(bottom_right.global_position.y)

func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = backroom_frontdoor_dest_marker.global_position
		transition_camera(b_top_left, b_bottom_right)

func _on_move_front_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = frontroom_backdoor_dest_marker.global_position
		transition_camera(f_top_left, f_bottom_right)

func _on_npc_spawner_npc_spawned(npc_instance : Node2D) -> void:
	if floor_map.shelf_targets.is_empty():
		return # no shelves in shop scene => no valid target for npcs
	setup_npc(npc_instance)
	add_child(npc_instance)
	npc_instance.move_to_point()

func setup_npc(npc : Node2D) -> void:
	npc.floor_map = floor_map
	npc.shelves = floor_map.shelf_targets.duplicate()
	npc.target = npc.shelves.pop_at(randi_range(0, len(npc.shelves) - 1))
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)

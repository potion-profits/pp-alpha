extends Node2D
@onready var floor_map : Node2D = $FrontRoom/AstarTilemap
@onready var frontroom_backdoor_dest_marker: Marker2D = $FrontRoom/frontroom_backdoor_dest_marker
@onready var backroom_frontdoor_dest_marker: Marker2D = $BackRoom/backdoor_frontroom_dest_marker
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D
@onready var f_top_left: Marker2D = $FrontRoom/FrontRoomEdges/TopLeft
@onready var f_bottom_right: Marker2D = $FrontRoom/FrontRoomEdges/BottomRight
@onready var b_top_left: Marker2D = $BackRoom/BackRoomEdges/TopLeft
@onready var b_bottom_right: Marker2D = $BackRoom/BackRoomEdges/BottomRight
@onready var static_ui: CanvasLayer = $Static_UI
@onready var inv_ui: Control = $Static_UI/Inv_UI
@onready var entity_manager: EntityManager = $EntityManager

var orig_inv_ui_pos: Vector2
var ui_tween: Tween

func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	orig_inv_ui_pos = inv_ui.position
	await get_tree().process_frame

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

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
	entity_manager.add_child(npc_instance)
	npc_instance.move_to_point()

func setup_npc(npc : Node2D) -> void:
	npc.floor_map = floor_map
	npc.shelves = floor_map.shelf_targets.duplicate()
	npc.target = npc.shelves.pop_at(randi_range(0, len(npc.shelves) - 1))
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)

func shift_ui(to_top: bool) -> void:
	if ui_tween and ui_tween.is_running():
		ui_tween.kill()
	
	var target_pos: Vector2
	if to_top:
		var offset_y: float = get_viewport().get_visible_rect().size.y * 0.825
		target_pos = Vector2(orig_inv_ui_pos.x, orig_inv_ui_pos.y - offset_y)
	else:
		target_pos = orig_inv_ui_pos
	
	ui_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	ui_tween.tween_property(inv_ui, "position", target_pos, 0.3)

func _on_bottom_collision_body_entered_frontroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(true)

func _on_bottom_collision_body_entered_backroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(true)

func _on_bottom_collision_body_exited_frontroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(false)

func _on_bottom_collision_body_exited_backroom(body: Node2D) -> void:
	if body is Player:
		shift_ui(false)

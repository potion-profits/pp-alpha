extends Node2D

## Handles NPC spawning and UI elements within the main shop scene

## Reference to scene's AstarGrid/floor tilemap, see astar.gd
@onready var floor_map : Node2D = $FrontRoom/AstarTilemap
## Marker for player transition to frontroom
@onready var frontroom_backdoor_dest_marker: Marker2D = $FrontRoom/frontroom_backdoor_dest_marker
## Marker for player transition to backroom
@onready var backroom_frontdoor_dest_marker: Marker2D = $BackRoom/backdoor_frontroom_dest_marker
## Camera centered on player
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D
## Top left corner of frontroom
@onready var f_top_left: Marker2D = $FrontRoom/FrontRoomEdges/TopLeft
## Bottom right corner of frontroom
@onready var f_bottom_right: Marker2D = $FrontRoom/FrontRoomEdges/BottomRight
## Top left corner of backroom
@onready var b_top_left: Marker2D = $BackRoom/BackRoomEdges/TopLeft
## Bottom right corner of backroom
@onready var b_bottom_right: Marker2D = $BackRoom/BackRoomEdges/BottomRight
## Coin UI element
@onready var static_ui: CanvasLayer = $Static_UI
## Inventory UI element
@onready var inv_ui: Control = $Static_UI/Inv_UI
## Scene's [EntityManager]
@onready var entity_manager: EntityManager = $EntityManager
## Background music for the shop
@onready var shop_music: AudioStreamPlayer = $ShopMusic

## Position of inventory UI
var orig_inv_ui_pos: Vector2
## Moves the inventory UI element
var ui_tween: Tween
## Condition if music playing
var music_on:bool = true

func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	orig_inv_ui_pos = inv_ui.position
	await get_tree().process_frame
#
func _process(_delta: float)->void:
	update_music_status()

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

## Moves the camera when the player transitions from the frontroom to the backroom or the backroom 
## to the frontroom
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

## Sets the paramaters for the [param npc] from the shop's [member floor_map]
func setup_npc(npc : Node2D) -> void:
	npc.floor_map = floor_map
	npc.shelves = floor_map.shelf_targets.duplicate()
	npc.target = npc.shelves.pop_at(randi_range(0, len(npc.shelves) - 1))
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)

## Handles dynamic movement of inventory UI when it blocks the player at the bottom of the screen
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

func update_music_status() -> void:
	if music_on:
		if !shop_music.playing:
			shop_music.play()
	else:
		shop_music.stop()
			

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

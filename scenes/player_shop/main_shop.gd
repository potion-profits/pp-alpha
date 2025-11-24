extends Node2D

@onready var frontroom_backdoor_dest_marker: Marker2D = $FrontRoom/frontdoor_backroom_dest_marker
@onready var backroom_frontdoor_dest_marker: Marker2D = $BackRoom/backdoor_frontroom_dest_marker
@onready var player_camera: Camera2D = $EntityManager/Player/Camera2D

@onready var backroom_topleft: Marker2D = $BackRoom/RoomEdges/top_left
@onready var backroom_bottomright: Marker2D = $BackRoom/RoomEdges/bottom_right
@onready var frontroom_topleft: Marker2D = $FrontRoom/RoomEdges/top_left
@onready var frontroom_bottomright: Marker2D = $FrontRoom/RoomEdges/bottom_right


func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	
	await get_tree().process_frame

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/casino/casino_menu.tscn")

func get_room_rect(tm_layer_wall: TileMapLayer, tm_layer_floor: TileMapLayer) -> Array[float]:
	var wall_coord: Rect2i = tm_layer_wall.get_used_rect()
	var floor_coord: Rect2i = tm_layer_floor.get_used_rect()
	var tile_size: Vector2i = tm_layer_wall.tile_set.tile_size
	
	# Top and left from walls
	var top_left_local: Vector2 = Vector2(wall_coord.position) * Vector2(tile_size)
	var top_left_global: Vector2 = tm_layer_wall.to_global(top_left_local)
	
	# Right from walls
	var right_local: Vector2 = Vector2(wall_coord.end.x, 0) * Vector2(tile_size)
	var right_global: Vector2 = tm_layer_wall.to_global(right_local)
	
	# Bottom from floor (so you don't see past the floor)
	var bottom_local: Vector2 = Vector2(0, floor_coord.end.y) * Vector2(tile_size)
	var bottom_global: Vector2 = tm_layer_floor.to_global(bottom_local)
	
	var edge_padding: int = tile_size.x 
	
	var left: float   = (top_left_global.x) + (edge_padding * 0.75)
	var top: float    = (top_left_global.y) + (edge_padding * 0.6)
	var right: float  = (right_global.x) - (edge_padding * 0.75)
	var bottom: float = (bottom_global.y) - (edge_padding * 0.4)
	
	return [left, top, right, bottom]

func transition_camera(top_left: Marker2D, bottom_right: Marker2D) -> void:
	player_camera.limit_left = int(top_left.global_position.x)
	player_camera.limit_top = int(top_left.global_position.y)
	player_camera.limit_right = int(bottom_right.global_position.x)
	player_camera.limit_bottom = int(bottom_right.global_position.y)

func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = backroom_frontdoor_dest_marker.global_position
		transition_camera(backroom_topleft, backroom_bottomright) 

func _on_move_front_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		body.global_position = frontroom_backdoor_dest_marker.global_position
		transition_camera(frontroom_topleft, frontroom_bottomright)

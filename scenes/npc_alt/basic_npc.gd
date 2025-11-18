extends CharacterBody2D
@onready var sprite : = $AnimatedSprite2D
var floor_map : Node2D

const TYPES : Array = [Color(1,0.5,0.5,1), Color(0.5,1,0.5,1), Color(0.5,0.5,1,1), Color(0.2,0.2,0.2,1)]
const SPEED : int = 100
const PROX_THRESHOLD : float = 2.0

enum movement_state {
	WALK,
	IDLE
}

enum action {
	GET_POTION,
	CHECKOUT,
	LEAVE
}

var current_state : movement_state = movement_state.IDLE
var current_action : action = action.GET_POTION
var current_path : Array = []
var path_index : int = 0
var last_dir : String = "up"
var shelves : Array
var target : Vector2i
var checkout : Vector2i

func _ready() -> void:
	var color : int = randi_range(0,TYPES.size() - 1)
	sprite.modulate = TYPES[color]

func _physics_process(_delta : float) -> void:
	velocity = Vector2.ZERO
	if current_path.is_empty():
		return
	var local_target : Vector2 = floor_map.tilemap.map_to_local(current_path[path_index])
	var direction : Vector2 = (local_target - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()
	
	if global_position.distance_to(local_target) < PROX_THRESHOLD:
		path_index += 1
		if path_index >= current_path.size():
			current_path = []
	
func move_to_point() -> void:
	var start_cell : Vector2i = floor_map.tilemap.local_to_map(global_position)
	var path : Array[Vector2i] = get_astar_path(start_cell, target)
	print(start_cell, "\n", path)
	if path.is_empty():
		return
	
	follow_path(path)

func follow_path(new_path : Array) -> void:
	current_path = new_path
	path_index = 0

func get_astar_path(start : Vector2i, end : Vector2i) -> Array[Vector2i]:
	var start_id : Vector2i = floor_map.tile_to_id(start)
	var end_id : Vector2i = floor_map.tile_to_id(end)
	
	var id_path : Array[Vector2i] = floor_map.astar.get_id_path(start_id, end_id)
	
	var tile_path : Array[Vector2i] = []
	for id_cell : Vector2i in id_path:
		tile_path.append(floor_map.id_to_tile(id_cell))
	
	return tile_path

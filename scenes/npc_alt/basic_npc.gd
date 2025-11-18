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
		animate(0,0)
		npc_action()
		return
	var local_target : Vector2 = floor_map.tilemap.map_to_local(current_path[path_index])
	var direction : Vector2 = (local_target - global_position).normalized()
	velocity = direction * SPEED
	animate(velocity.x, velocity.y)
	move_and_slide()
	
	if global_position.distance_to(local_target) < PROX_THRESHOLD:
		path_index += 1
		if path_index >= current_path.size():
			current_path = []
	
func move_to_point() -> void:
	if target == null:
		return
	var start_cell : Vector2i = floor_map.tilemap.local_to_map(global_position)
	var path : Array[Vector2i] = get_astar_path(start_cell, target)
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

func npc_action() -> void:
	set_physics_process(false)
	match current_action:
		action.GET_POTION:
			# check shelf for potion
			var roll : int = randi_range(1,6)
			if roll > 2:
				current_action = action.CHECKOUT
				target = checkout
				move_to_point()
			else:
				if shelves.is_empty():	# no more shelves to visit
					current_action = action.LEAVE
					target = floor_map.spawn
					move_to_point()
				else:
					var next_shelf : int = randi_range(0, len(shelves) - 1)
					target = shelves.pop_at(next_shelf)
					move_to_point()
		action.CHECKOUT:
			current_action = action.LEAVE
			target = floor_map.spawn
			move_to_point()
		action.LEAVE:
			queue_free()
	await get_tree().create_timer(5.0).timeout
	set_physics_process(true)

func animate(x_dir: float, y_dir : float) -> void:
	var anim_dir := ""
	if Vector2(x_dir, y_dir) != Vector2.ZERO:
		if y_dir < 0:
			anim_dir = "up"
		elif y_dir > 0:
			anim_dir = "down"
		
		if x_dir < 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
				sprite.flip_h = false
		elif x_dir > 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
				sprite.flip_h = true
		
		last_dir = anim_dir
		
		if anim_dir != "":
			if sprite.sprite_frames.has_animation("walking_" + anim_dir):
				sprite.play("walking_" + anim_dir)
	else:
		if sprite.sprite_frames.has_animation("idle_" + last_dir):
			sprite.play("idle_" + last_dir)

class_name Npc extends CharacterBody2D

## This class represents the shop NPCs and includes methods for pathing, a state machine to manage
## actions, and a system to find and checkout a prefered item(s)

## See [AnimatedSprite2D]
@onready var sprite : = $AnimatedSprite2D
## Determines how long an NPC waits at checkout
@onready var checkout_timer: Timer = $CheckoutTimer
## Determines how long an NPC waits before moving to their next target
@onready var wait_timer: Timer = $WaitTimer

## References the floor tilemap of the main shop scene
var floor_map : Node2D
## [b]NOT USED IN CURRENT BUILD[/b][br]To be added in future releases for mutliple-potion carts,
## arbitrarily set to one in current build
var inv : Inv = Inv.new(1)

const SPEED : int = 100
const PROX_THRESHOLD : float = 2.0
const CHECKOUT_TIME : float = 10.0

## States utilized in the state machine for NPC pathing decisions
enum action {
	GET_POTION,
	CHECKOUT,
	LEAVE
}

## Represents the current state of the NPC
var current_action : action = action.GET_POTION
## Represents the astar path of the NPC
var current_path : Array = []
## Represents the current index of the NPC's path
var path_index : int = 0
## Represents the last direction of the NPC
var last_dir : String = "up"
## Stores tilemap coordinates for each shelf in the main shop
var shelves : Array
## Represents thte current target on the tilemap that the NPC is moving towards
var target : Vector2i
## Represents the checkout tile
var checkout : Vector2i
## Represents the NPC's prefered item that they will shop for
var prefered_item : String = "item_red_potion"
## Tracks if the perfered item has been found by the NPC
var item_found : bool = false
## Tracks if the NPC has been checked out
var is_checked_out : bool = false

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

## Determines the path from the NPC's current position to its target utilizing the floor tilemap
## from the main shop and the astar grid of the tilemap. See [b]astar.gd[/b]
func move_to_point() -> void:
	if target == null:
		return
	var start_cell : Vector2i = floor_map.tilemap.local_to_map(global_position)
	var path : Array[Vector2i] = get_astar_path(start_cell, target)
	if path.is_empty():
		return
	current_path = path
	path_index = 0

## Retreives the path from the [param start] tile to the [param end] tile. In order to utilize the
## astar grid pathing algorithm, the tiles must be converted into their respective astar ids:[br]
## [code]var start_id : Vector2i = floor_map.tile_to_id(start)[/code][br]
## [code]var end_id : Vector2i = floor_map.tile_to_id(end)[/code][br]
## Then the actual path may be acquired using the built in astar call:[br]
## [code]var id_path : Array[Vector2i] = floor_map.astar.get_id_path(start_id, end_id)[/code][br]
## Before returning, the entire path is in astar ids and must be converted into tilemap tiles:
## [codeblock]
## for id_cell : Vector2i in id_path:
##	tile_path.append(floor_map.id_to_tile(id_cell))
## [/codeblock]
func get_astar_path(start : Vector2i, end : Vector2i) -> Array[Vector2i]:
	var start_id : Vector2i = floor_map.tile_to_id(start)
	var end_id : Vector2i = floor_map.tile_to_id(end)
	var id_path : Array[Vector2i] = floor_map.astar.get_id_path(start_id, end_id)
	var tile_path : Array[Vector2i] = []
	for id_cell : Vector2i in id_path:
		tile_path.append(floor_map.id_to_tile(id_cell))
	
	return tile_path

## State machine to determine the next NPC action after reaching the end of its path.
func npc_action() -> void:
	set_physics_process(false)
	match current_action:
		action.GET_POTION:
			# check shelf for potion
			if item_found:
				move_to_checkout()
			else:
				if shelves.is_empty():	# no more shelves to visit
					move_to_spawn()
				else:
					var next_shelf : int = randi_range(0, len(shelves) - 1)
					target = shelves.pop_at(next_shelf)
					move_to_point()
			wait_timer.start(2.0)
			await wait_timer.timeout
		action.CHECKOUT:
			if not is_checked_out:
				checkout_timer.start(CHECKOUT_TIME)
				await checkout_timer.timeout
			move_to_spawn()
		action.LEAVE:
			queue_free()
	set_physics_process(true)

## Animates the NPC based on velocity determined by movement along path
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

## State and target update for movement to checkout
func move_to_checkout() -> void:
	current_action = action.CHECKOUT
	target = checkout
	move_to_point()

## State and target update for movement to leave the shop
func move_to_spawn() -> void:
	current_action = action.LEAVE
	target = floor_map.spawn
	move_to_point()

## Checks the entered [param shelf] for the NPC's prefered item. If found, it will remove one of
## the item from the shelf and then proceed to checkout.
func check_shelf(shelf : Entity) -> void:
	if (item_found):
		return
	var tmp : Array[InvSlot] = shelf.get_inventory()
	for i in range(tmp.size()):
		var item : = tmp[i]
			
		if (item.amount > 0 and item.item.texture_code == prefered_item and item.item.sellable):
			item_found = true
			shelf.remove_item(i, 1)
			move_to_checkout()
			break

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

class_name ShopNpc extends Npc

## This class represents the shop NPCs and includes methods for pathing, a state machine to manage
## actions, and a system to find and checkout a prefered item(s)

## Determines how long an NPC waits at checkout
@onready var checkout_timer: Timer = $CheckoutTimer
## Determines how long an NPC waits before moving to their next target
@onready var wait_timer: Timer = $WaitTimer
## References the floor tilemap of the main shop scene
var floor_map : Node2D
## [b]NOT USED IN CURRENT BUILD[/b][br]To be added in future releases for mutliple-potion carts,
## arbitrarily set to one in current build
var inv : Inv = Inv.new(1)

## References the return basket
var return_basket : ReturnBasket

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
## Tracks if the NPC has been triggered to leave
var has_left: bool = false

## Used to map the shop NPC's class to its prefered item
var prefered_item_map : Dictionary = {
	"fighter": "item_red_potion",
	"druid": "item_green_potion",
	"mage": "item_blue_potion",
	"rogue": "item_dark_potion"
}

func _ready() -> void:
	super._ready()
	prefered_item = prefered_item_map[npc_class]
	change_state(current_action)

func _physics_process(_delta : float) -> void:
	velocity = Vector2.ZERO
	if current_path.is_empty():
		animate(0,0)
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
			on_reached_destination()

## Changes the NPC's state to the given action
func change_state(new_state : action) -> void:
		current_action = new_state
		enter_state(new_state)

## Calls proper NPC function based on the given state
func enter_state(state : action) -> void:
	match state:
		action.GET_POTION:
			potion_action()
		action.CHECKOUT:
			checkout_action()
		action.LEAVE:
			leave_action()

## State in which NPC looks for a potion at each shelf
func potion_action() -> void:
	# check shelf for potion
	if item_found:
		change_state(action.CHECKOUT)
		return
	if shelves.is_empty():	# no more shelves to visit
		change_state(action.LEAVE)
		return
	var next_shelf : int = randi_range(0, len(shelves) - 1)
	target = shelves.pop_at(next_shelf)
	move_to_point()

func checkout_action() -> void:
	target = checkout
	move_to_point()

func leave_action() -> void:
	target = floor_map.spawn
	move_to_point()

func on_reached_destination() -> void:
	match current_action:
		action.GET_POTION:
			wait_timer.start(2.0)
			await wait_timer.timeout
			change_state(action.GET_POTION)
		action.CHECKOUT:
			if not is_checked_out:
				checkout_timer.start(CHECKOUT_TIME)
				await checkout_timer.timeout
			change_state(action.LEAVE)
		action.LEAVE:
			if has_left:
				return
			
			has_left = true
			
			if not is_checked_out and item_found:
				var returned_item : InvItem = ItemRegistry.new_item(prefered_item)
				returned_item.sellable = true
				returned_item.mixable = false
				return_basket.return_item(returned_item)
			
			queue_free()
	
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
			change_state(action.CHECKOUT)
			break

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

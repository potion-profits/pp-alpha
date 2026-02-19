extends Node2D

## Reference to player character
@onready var player: Player = $Player
## Reference to static camera in front room
@onready var front_cam: Camera2D = $FrontRoom/FrontCam
## Reference to static camera in back room
@onready var back_cam: Camera2D = $BackRoom/BackCam
## Reference to the layer containing all placed entities
@onready var entity_layer: TileMapLayer = $EntityLayer
## Reference to the layer continaing the previewed placement
@onready var preview_layer: TileMapLayer = $PreviewLayer
## Reference to the floors in the back room
@onready var back_floor: TileMapLayer = $BackRoom/BackroomFloors
## Reference to the floors in the front room
@onready var front_floor: TileMapLayer = $FrontRoom/Floor
## Reference to the checkout counter tiles
@onready var counters: TileMapLayer = $FrontRoom/Counters
## Reference to the entity manager 
@onready var em: EntityManager = $EntityManager
## Reference to the price label
@onready var cost: Label = $Static_UI/CostContainer/Cost
## Reference to the smooth movement handler
@onready var hold_controller: DirectionalHoldController = $DirectionalHoldController

var original_pos : Vector2

## Holds the position of the currently hovered tile
var current_tile: Vector2i = Vector2i.ZERO
## Holds the floor of the current room accessed
var current_layer:TileMapLayer = front_floor

var topleft : Vector2i	## The top left corner of the floor for bounds checking
var botright : Vector2i	## The bottom right corner for bounds checking

const SHELF_IDX = 3	## Holds a constant refence to the shelf

## Holds the index of the currently cycled entity
var current_entity_idx: int = SHELF_IDX
## Order of all entities used for cycling
const ENTITY_ORDER: Array = ["barrel", "crate", "cauldron", "shelf"]
## Holds the code of the currently selected entity
var current_entity: String = ENTITY_ORDER[current_entity_idx]

## Flag to allow placement only after scene is done loading
var done_loading:bool = false

## Holds the position of the last tile
var _last_tile : Vector2i = Vector2i(-9999, -9999)
## Holds the previous entity's code
var _last_entity : String = ""
## Holds the previous valid flag
var _last_valid : bool = false

## The scene number for an invalid placement block
const BLOCK_ID: int = 6

## Holds the information of each placable entities
const ENTITIES : Dictionary = {
	"barrel": {
		"tile_id": 1,
		"price": 30,
		"blocks_above": false,
	},
	"bed":{
		"tile_id": 2,
		"price": INF,
		"blocks_above": true,
	},
	"crate": {
		"tile_id": 3,
		"price": 20,
		"blocks_above": false,
	},
	"cauldron": {
		"tile_id": 4,
		"price": 60,
		"blocks_above": false,
	},
	"shelf": {
		"tile_id": 5,
		"price": 40,
		"blocks_above": true,
	},
}

## The tileset source id
const TILESET_SOURCE : int = 0
## Used to check if a tile is empty
const EMPTY_TILE : int = -1
## Used to modulate on invalid placement
const INVALID_COLOR : Color = Color("Red")
## Used to modulate on valid placement
const VALID_COLOR : Color = Color("White")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connects the movement signal from controller to on step
	hold_controller.stepped.connect(_on_step)
	
	# default to front room
	front_cam.make_current()
	current_layer = front_floor
	_update_bounds()
	
	# default to top left tile
	current_tile = topleft
	update_price()
	
	# wait a frame so the entities load properly
	await get_tree().process_frame
	# places the entities on the proper tile
	
	player.set_physics_process(false) # need gold but dont want to move charactser
	original_pos = player.global_position
	player.global_position = Vector2.ZERO
	
	_restore_entities_to_tilemap()
	update_price()

# Switches to and from back and front room
func _switch_cam() -> void:
	if front_cam.is_current():
		switch_to_back()
	else:
		switch_to_front()
	reset_cursor()

## Removes the current preview tile and places the cursor at the top left
func reset_cursor() -> void:
	preview_layer.erase_cell(current_tile)
	current_tile = topleft

## Switch to the back room
func switch_to_back() -> void:
	back_cam.make_current()
	current_layer = back_floor
	_update_bounds()

## Switch to the front room
func switch_to_front() -> void:
	front_cam.make_current()
	current_layer = front_floor
	current_entity_idx = SHELF_IDX
	current_entity = ENTITY_ORDER[current_entity_idx]
	update_price()
	_update_bounds()
	
# update the top left and bottom right bounds
func _update_bounds() -> void:
	var tiles : Array = current_layer.get_used_cells()
	topleft = tiles[0]
	botright = tiles[0]
	
	for tile:Vector2i in tiles:
		topleft = Vector2i(min(topleft.x, tile.x), min(topleft.y, tile.y))
		botright = Vector2i(max(botright.x, tile.x), max(botright.y, tile.y))


## moves to the tile in the given direction delta
func move_cursor(dir_delta : Vector2i) -> void:
	var next : Vector2i = current_tile + dir_delta
	if next.x < topleft.x or next.x > botright.x:
		return
	if next.y < topleft.y or next.y > botright.y:
		return
	current_tile = next

# When a movement signal is sent, move the cursor
func _on_step(dir: DirectionalHoldController.Direction)->void:
	move_cursor(hold_controller.get_vector(dir))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_switch_cam()
	
	if event.is_action_pressed("interact"):
		_place()
	
	if event.is_action_pressed("ui_accept"):
		_cycle()
		
	if event.is_action_pressed("ui_cancel"):
		_menu()
		get_viewport().set_input_as_handled()
		
	hold_controller.handle_movement_input(event)

# place entity and subtract money
func _place() -> void:
	if not done_loading:
		return

	if not can_place_entity(current_tile):
		return
	
	place_entity(current_tile)
	if player.credits[current_entity]:
		player.set_credit(current_entity, -1)
		update_price()
	else:
		player.set_coins(-(entity_info().price))
	

## Moves the preview layer entity to the entity layer
func place_entity(tile: Vector2i) -> void:
	entity_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, entity_info().tile_id)
	
	if entity_info().blocks_above:
		entity_layer.set_cell(tile + Vector2i.UP, TILESET_SOURCE, Vector2i.ZERO, BLOCK_ID)
	preview_layer.erase_cell(tile)
	_save_tile()

# cycle through the possible entities
func _cycle() -> void:
	if current_layer == front_floor:
		current_entity_idx = SHELF_IDX
	else:
		current_entity_idx = (current_entity_idx+1) % ENTITY_ORDER.size()
	
	current_entity = ENTITY_ORDER[current_entity_idx]
	update_price()

# change the price label to reflect the current entity's price
func update_price()->void:
	var this_cred : int = player.credits[current_entity]
	if this_cred:
		cost.text = "FREE!!"
	else:
		cost.text = str(-entity_info().price)

# every frame, try to update the preview and process any movement
func _process(delta: float) -> void:
	update_preview()
	hold_controller.process(delta)

## Updates the preview layer to show on correct tile and color based on validity
func update_preview()->void:
	# check if tile is free to place
	var valid : bool = can_place_entity(current_tile)
	
	if _tile_state_unchanged(valid):
		return
	
	# ensure nothing else is on the preview
	preview_layer.clear()
	draw_preview_tile(current_tile, valid) # draw the tile
	_update_tile_state(valid)	#update its state

# check the state of the tile
func _tile_state_unchanged(valid : bool) -> bool:
	return current_tile == _last_tile and current_entity == _last_entity and valid == _last_valid

# update the state of the tile
func _update_tile_state(valid : bool) -> void:
	_last_entity = current_entity
	_last_tile = current_tile
	_last_valid = valid

## Draw the current entity on the current tile of the preview layer
func draw_preview_tile(tile: Vector2i, valid: bool) -> void:
	preview_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, entity_info().tile_id)
	preview_layer.modulate = VALID_COLOR if valid else INVALID_COLOR

## Commits the preview layer entity into the entity manager at the current location
func _save_tile() -> void:
	var local_coords: Vector2 = preview_layer.map_to_local(current_tile)
	var placed_entity:Entity = em.create_entity(current_entity)
	placed_entity.position = local_coords
	em.add_child(placed_entity)

# Returns true if the given tile on the given layer is empty
func _empty_cell(layer: TileMapLayer, coords: Vector2i) -> bool:
	return layer.get_cell_source_id(coords) == EMPTY_TILE
	
# Goes through all entities and draws them on a tilemap
func _restore_entities_to_tilemap()->void:
	for entity in em.get_children():
		if entity.is_in_group("entity"):
			_restore_tile(entity.entity_code, entity_layer.local_to_map(entity.position))
	done_loading = true

# Draws the given entity onto the given tile 
func _restore_tile(entity_code:String, tile: Vector2i)->void:
	entity_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, ENTITIES[entity_code].tile_id)
	
	if entity_code == "shelf" or entity_code == "bed":
		entity_layer.set_cell(tile + Vector2i.UP, TILESET_SOURCE, Vector2i.ZERO, BLOCK_ID)
	
## Returns true if tbe given tile can have something placed on it
func can_place_entity(tile : Vector2i) -> bool:
	if not _empty_cell(entity_layer, tile):
		return false
	
	if not _empty_cell(counters, tile):
		return false
	
	if entity_info().blocks_above:
		var above : Vector2i = tile + Vector2i.UP
		if not _empty_cell(entity_layer, above):
			return false
	
	if entity_info().price > player.get_coins() and player.credits[current_entity] <= 0:
		return false
	
	return true

# returns to menu, should change to shop when merged
func _menu()->void:
	player.global_position = original_pos
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")
	
## Returns the info of the current entity from ENTITIES
func entity_info() -> Dictionary:
	return ENTITIES[current_entity]

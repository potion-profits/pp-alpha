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
## Reference to the entity manager 
@onready var em: EntityManager = $EntityManager
## Reference to the smooth movement handler
@onready var hold_controller: DirectionalHoldController = $DirectionalHoldController

var original_pos : Vector2

## Holds the position of the currently hovered tile
var current_tile: Vector2i = Vector2i.ZERO
## Holds the floor of the current room accessed
var current_layer:TileMapLayer = front_floor
## Holds the current entity that is being hover
var current_entity:Entity

## Holds all the selectable entities on each floor
var f_selectables : Array = []
var b_selectables : Array = []

var f_idx : int = 0
var b_idx : int = 0

## Flag to allow placement only after scene is done loading
var done_loading:bool = false

## Holds the information of each placable entities
const ENTITY_SCENE_ID : Dictionary = {
	"barrel": 1,
	"bed": 2,
	"crate": 3,
	"cauldron": 4,
	"shelf": 5,
}

## The tileset source that holds the store icon
const TILESET_SOURCE = 0
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
	
	# wait a frame so the entities load properly
	await get_tree().process_frame
	# places the entities on the proper tile
	
	player.set_physics_process(false) # need gold but dont want to move charactser
	original_pos = player.global_position
	player.global_position = Vector2.ZERO
	
	_restore_entities_to_tilemap()
	
	_find_init_target()

# Finds all targets and makes the first one the current
func _find_init_target() -> void:
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code in ENTITY_SCENE_ID.keys():
				# only set current_entity if one hasnt been set
				if _at_front(child):
					f_selectables.append(child)
					if not current_entity:
						current_entity = child
				else:
					if child.entity_code != "bed":
						b_selectables.append(child)
	if not f_selectables:
		if not b_selectables:
			return
		current_entity = b_selectables[0]
		_switch_cam()
	
	if current_entity:
		current_tile = current_layer.local_to_map(current_entity.position)

func _at_front(entity : Entity) -> bool:
	return front_floor.local_to_map(entity.position) in front_floor.get_used_cells()

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

## Switch to the back room
func switch_to_back() -> void:
	back_cam.make_current()
	current_layer = back_floor
	if b_selectables:
		current_entity = b_selectables[0]
		current_tile = current_layer.local_to_map(current_entity.position)

## Switch to the front room
func switch_to_front() -> void:
	front_cam.make_current()
	current_layer = front_floor
	if f_selectables:
		current_entity = f_selectables[0]
		current_tile = current_layer.local_to_map(current_entity.position)

# When a movement signal is sent, move the cursor
func _on_step(dir: DirectionalHoldController.Direction)->void:
		# Get the held direction
	var delta : Vector2i = DirectionalHoldController.DIR_VECTORS.get(dir)
	
	# if no direction, don't do anything
	if delta == null:
		return
	
	# get the next entity in the given direction
	var next_entity : Entity = find_next_selectable(delta)
	
	# if the closest is the current, dont change
	if next_entity == current_entity:
		return
		
	current_entity.modulate = VALID_COLOR
	current_entity = next_entity
	
	if current_entity:
		current_tile = current_layer.local_to_map(current_entity.position)
	
	update_preview()

func find_next_selectable(_delta : Vector2i) -> Entity:
	if current_layer == front_floor:
		if f_selectables:
			f_idx = (f_idx + 1) % len(f_selectables)
			return f_selectables[f_idx]
	else:
		if b_selectables:
			b_idx = (b_idx + 1) % len(b_selectables)
			return b_selectables[b_idx]
	return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_switch_cam()
	
	if event.is_action_pressed("interact"):
		_delete()
		
	if event.is_action_pressed("ui_cancel"):
		_menu()
		get_viewport().set_input_as_handled()
		
	hold_controller.handle_movement_input(event)

# place entity and subtract money
func _delete() -> void:
	if not done_loading:
		return
	if not current_entity:
		return
	var stored_code : String = current_entity.entity_code
	delete_entity(current_tile)
	player.set_credit(stored_code, +1)
	
## Moves the preview layer entity to the entity layer
func delete_entity(tile: Vector2i) -> void:
	entity_layer.erase_cell(tile)
	if current_layer == front_floor:
		f_selectables.erase(current_entity)
	else:
		b_selectables.erase(current_entity)
	_save_deletion()
	current_entity = find_next_selectable(Vector2i.ZERO)
	if current_entity:
		current_tile = current_layer.local_to_map(current_entity.position)

# every frame, try to update the preview and process any movement
func _process(delta: float) -> void:
	update_preview()
	hold_controller.process(delta)

## Updates the preview layer to show on correct tile and color based on validity
func update_preview()->void:
	if current_entity and current_entity.modulate != INVALID_COLOR:
		current_entity.modulate = INVALID_COLOR


## Draw the current entity on the current tile of the preview layer
func draw_preview_tile(tile: Vector2i, valid: bool) -> void:
	preview_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, entity_info())
	preview_layer.modulate = VALID_COLOR if valid else INVALID_COLOR

## Commits the preview layer entity into the entity manager at the current location
func _save_deletion() -> void:
	current_entity.free()

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
	entity_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, ENTITY_SCENE_ID[entity_code])
	
## Returns true if tbe given tile can have something placed on it
func can_delete_entity(tile : Vector2i) -> bool:
	if _empty_cell(entity_layer, tile):
		return false
	return true

# returns to menu, should change to shop when merged
func _menu()->void:
	player.global_position = original_pos
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")
	
## Returns the info of the current entity from ENTITIES
func entity_info() -> int:
	return ENTITY_SCENE_ID[current_entity.entity_code]

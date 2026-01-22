extends Node2D

@onready var player: Player = $Player
@onready var front_cam: Camera2D = $FrontRoom/FrontCam
@onready var back_cam: Camera2D = $BackRoom/BackCam
@onready var entity_layer: TileMapLayer = $EntityLayer
@onready var back_floor: TileMapLayer = $BackRoom/BackroomFloors
@onready var front_floor: TileMapLayer = $FrontRoom/Floor
@onready var temp_layer: TileMapLayer = $TempLayer
@onready var counters: TileMapLayer = $FrontRoom/Counters
@onready var em: EntityManager = $EntityManager
@onready var cost: Label = $Static_UI/HBoxContainer/Cost

var current_tile: Vector2i = Vector2i.ZERO
var current_layer:TileMapLayer = front_floor

var topleft : Vector2i
var botright : Vector2i

const SHELF_IDX = 3

var current_entity_idx: int = SHELF_IDX
const entity_arr: Array = ["barrel", "crate", "cauldron", "shelf"]
const entity_prices: Array = [10, 20, 30, 40]
var current_entity: String = entity_arr[current_entity_idx]
# delays for moving through selections
var first_delay: float = 0.3	## Threshold to start moving after initially holding.
var repeat_delay: float = 0.1	## Threshold to continue moving while holding.
var hold_time: float = 0.0	## Time [member holding_dir] has been held since last move.

var done_loading:bool = false
# switch for repeat delay toggle
var repeat : bool = false ## Flag for handling moving while holding

var holding_dir : Direction = Direction.NONE ## Tells what direction is being held.

## All possible directions the selection can move & none for when it should not move.
enum Direction{
	NONE,
	LEFT,
	RIGHT,
	UP,		# not used yet but will likely be useful when on grid
	DOWN	# not used yet but will likely be useful when on grid
}

const BLOCK_ID: int = 6
const ENTITY_ID: Dictionary = {
	"barrel": 1,
	"bed": 2,
	"crate": 3,
	"cauldron": 4,
	"shelf": 5
}

const ENTITY_SOURCE : int = 0
const EMPTY_TILE : int = -1
const INVALID_COLOR : Color = Color("Red")
const VALID_COLOR : Color = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false) # need gold but dont want to move charactser
	
	front_cam.make_current()
	current_layer = front_floor
	_update_bounds()
	current_tile = topleft
	_update_price()
	
	await get_tree().process_frame
	_update_floors()

# Switches to and from back and front room
func _switch_cam() -> void:
	@warning_ignore("standalone_ternary")
	if front_cam.is_current():
		back_cam.make_current()
		current_layer = back_floor
	else:
		front_cam.make_current()
		current_layer = front_floor
		current_entity_idx = SHELF_IDX
		current_entity = entity_arr[current_entity_idx]
		_update_price()

	_update_bounds()
	temp_layer.erase_cell(current_tile)
	current_tile = topleft

func _update_bounds() -> void:
	var tiles : Array = current_layer.get_used_cells()
	topleft = tiles[0]
	botright = tiles[0]
	
	for tile:Vector2i in tiles:
		topleft = Vector2i(min(topleft.x, tile.x), min(topleft.y, tile.y))
		botright = Vector2i(max(botright.x, tile.x), max(botright.y, tile.y))

func _move_right()->void:
	if current_tile.x + 1 <= botright.x:
			temp_layer.erase_cell(current_tile)
			current_tile.x += 1

func _move_left() -> void:
	if current_tile.x - 1 >= topleft.x:
		temp_layer.erase_cell(current_tile)
		current_tile.x -= 1
		
func _move_down() -> void:
	if current_tile.y + 1 <= botright.y:
		temp_layer.erase_cell(current_tile)
		current_tile.y += 1

func _move_up() -> void:
	if current_tile.y - 1 >= topleft.y:
		temp_layer.erase_cell(current_tile)
		current_tile.y -= 1

## Turns on the holding mechanism for smoother selection
func _start_hold(dir: Direction) -> void:
	holding_dir = dir
	hold_time = 0.0
	repeat = false
	_step()
	
## Turns off the holding mechanism for smoother selection
func _stop_hold()->void:
	holding_dir = Direction.NONE
	
## Changes selected target to the target in the corresponding held direction
func _step() -> void:
	match holding_dir:
		Direction.LEFT:
			_move_left()
		Direction.RIGHT:
			_move_right()
		Direction.UP:
			_move_up()
		Direction.DOWN:
			_move_down()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		_stop_hold()
		_switch_cam()
	
	if event.is_action_pressed("move_right"):
		_start_hold(Direction.RIGHT)
		
	if event.is_action_pressed("move_left"):
		_start_hold(Direction.LEFT)
		
	if event.is_action_pressed("move_down"):
		_start_hold(Direction.DOWN)
		
	if event.is_action_pressed("move_up"):
		_start_hold(Direction.UP)
		
	if event.is_action_released("move_left") and holding_dir == Direction.LEFT:
		_stop_hold()
	
	if event.is_action_released("move_right") and holding_dir == Direction.RIGHT:
		_stop_hold()
		
	if event.is_action_released("move_down") and holding_dir == Direction.DOWN:
		_stop_hold()
	
	if event.is_action_released("move_up") and holding_dir == Direction.UP:
		_stop_hold()
	
	if event.is_action_pressed("interact"):
		_stop_hold()
		_place()
	
	if event.is_action_pressed("ui_cancel"):
		_menu()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("ui_accept"):
		_stop_hold()
		_cycle()

func _place() -> void:
	if not done_loading:
		return

	if temp_layer.modulate == VALID_COLOR:
		entity_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, ENTITY_ID[current_entity])
		if(current_entity == "shelf"):
			entity_layer.set_cell(current_tile + Vector2i.UP, ENTITY_SOURCE, Vector2i.ZERO, BLOCK_ID)
		temp_layer.erase_cell(current_tile)
		_save_tile()
		player.set_coins(-entity_prices[current_entity_idx])

func _cycle() -> void:
	if current_layer == front_floor:
		current_entity_idx = SHELF_IDX
	else:
		current_entity_idx = (current_entity_idx+1) % len(entity_arr)
	
	current_entity = entity_arr[current_entity_idx]
	_update_price()

func _update_price()->void:
	var price : int  = entity_prices[current_entity_idx]
	cost.text = str(-price)

func _process(delta: float) -> void:
	_draw_tile()
	
	if holding_dir == Direction.NONE:	# basecase, dont move
		return
	
	hold_time += delta	# how long since direction was pressed
	
	# if repeated movements has not been toggled
	if not repeat:
		# if the direction has been held long enough to move to the next one 
		if hold_time >= first_delay:
			repeat = true	# enable repeated movements in the same direction
			hold_time = 0.0 # reset the hold timer
	
	# if movements should be repeated (ie. the direction is being held)
	else:
		if hold_time >= repeat_delay:	# if direction is held enough to move again
			hold_time = 0.0 # reset the hold timer
			_step()	# move to the corresponding target

func _draw_tile()->void:
	if _empty_cell(entity_layer, current_tile) and _empty_cell(counters, current_tile):
		var VALIDITY:Color = VALID_COLOR
		if current_entity_idx == SHELF_IDX and not _empty_cell(entity_layer, Vector2i(current_tile.x, current_tile.y - 1)):
			VALIDITY = INVALID_COLOR
		if(entity_prices[current_entity_idx]> player.get_coins()):
			VALIDITY = INVALID_COLOR
		temp_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, ENTITY_ID[current_entity])
		temp_layer.modulate = VALIDITY
		
	elif _empty_cell(temp_layer, current_tile) or temp_layer.modulate == INVALID_COLOR:
		temp_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, ENTITY_ID[current_entity])
		temp_layer.modulate = INVALID_COLOR
	else:
		return

func _save_tile() -> void:
	var local_coords: Vector2 = temp_layer.map_to_local(current_tile)
	var placed_entity:Entity = em.create_entity(current_entity)
	placed_entity.position = local_coords
	em.add_child(placed_entity)

func _empty_cell(layer: TileMapLayer, coords: Vector2i) -> bool:
	return layer.get_cell_source_id(coords) == EMPTY_TILE
	
func _update_floors()->void:
	for entity in em.get_children():
		if entity.is_in_group("entity"):
			_restore_tile(entity.entity_code, entity_layer.local_to_map(entity.position))
	done_loading = true

func _restore_tile(entity_code:String, tile: Vector2i)->void:
	entity_layer.set_cell(tile, ENTITY_SOURCE, Vector2i.ZERO, ENTITY_ID[entity_code])
	
	if entity_code == "shelf" or entity_code == "bed":
		entity_layer.set_cell(tile + Vector2i.UP, ENTITY_SOURCE, Vector2i.ZERO, BLOCK_ID)
	

func _menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

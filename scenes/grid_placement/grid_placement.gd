extends Node2D

@onready var player: Player = $Player
@onready var front_cam: Camera2D = $FrontRoom/FrontCam
@onready var back_cam: Camera2D = $BackRoom/BackCam
@onready var entity_layer: TileMapLayer = $EntityLayer
@onready var back_floor: TileMapLayer = $BackRoom/BackroomFloors
@onready var front_floor: TileMapLayer = $FrontRoom/Floor
@onready var temp_layer: TileMapLayer = $TempLayer
@onready var counters: TileMapLayer = $FrontRoom/Counters

var current_tile: Vector2i = Vector2i.ZERO
var current_layer:TileMapLayer = front_floor

var topleft : Vector2i
var botright : Vector2i

var current_entity: ENTITY = ENTITY.BARREL

# delays for moving through selections
var first_delay: float = 0.3	## Threshold to start moving after initially holding.
var repeat_delay: float = 0.1	## Threshold to continue moving while holding.
var hold_time: float = 0.0	## Time [member holding_dir] has been held since last move.

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

enum ENTITY{
	BARREL = 1,
	BED = 2,
	CRATE = 3,
	CAULDRON = 4,
	SHELF = 5
}


const ENTITY_SOURCE : int = 0
const EMPTY_TILE : int = -1
const INVALID_COLOR : Color = Color("Red")
const VALID_COLOR : Color = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false) # need gold but dont want to move character
	front_cam.make_current()
	current_layer = front_floor
	_update_bounds()
	current_tile = topleft

# Switches to and from back and front room
func _switch_cam() -> void:
	@warning_ignore("standalone_ternary")
	back_cam.make_current() if front_cam.is_current() else front_cam.make_current()
	current_layer = back_floor if back_cam.is_current() else front_floor
	_update_bounds()
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

func _place() -> void:
	if temp_layer.modulate == VALID_COLOR:
		entity_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, current_entity)
		temp_layer.erase_cell(current_tile)

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
		temp_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, current_entity)
		temp_layer.modulate = VALID_COLOR
	elif _empty_cell(temp_layer, current_tile):
		temp_layer.set_cell(current_tile, ENTITY_SOURCE, Vector2i.ZERO, current_entity)
		temp_layer.modulate = INVALID_COLOR
	else:
		return

func _empty_cell(layer: TileMapLayer, coords: Vector2i) -> bool:
	return layer.get_cell_source_id(coords) == EMPTY_TILE

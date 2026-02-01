extends Node2D

@onready var player: Player = $Player
@onready var front_cam: Camera2D = $FrontRoom/FrontCam
@onready var back_cam: Camera2D = $BackRoom/BackCam
@onready var entity_layer: TileMapLayer = $EntityLayer
@onready var preview_layer: TileMapLayer = $PreviewLayer
@onready var back_floor: TileMapLayer = $BackRoom/BackroomFloors
@onready var front_floor: TileMapLayer = $FrontRoom/Floor
@onready var counters: TileMapLayer = $FrontRoom/Counters
@onready var em: EntityManager = $EntityManager
@onready var cost: Label = $Static_UI/HBoxContainer/Cost
@onready var hold_controller: DirectionalHoldController = $DirectionalHoldController


const MOVE_ACTIONS : Dictionary = {
	"move_left": hold_controller.Direction.LEFT,
	"move_right": hold_controller.Direction.RIGHT,
	"move_up": hold_controller.Direction.UP,
	"move_down": hold_controller.Direction.DOWN,
}


var current_tile: Vector2i = Vector2i.ZERO
var current_layer:TileMapLayer = front_floor

var topleft : Vector2i
var botright : Vector2i

const SHELF_IDX = 3

var current_entity_idx: int = SHELF_IDX
const ENTITY_ORDER: Array = ["barrel", "crate", "cauldron", "shelf"]
var current_entity: String = ENTITY_ORDER[current_entity_idx]

var done_loading:bool = false


var _last_tile : Vector2i = Vector2i(-9999, -9999)
var _last_entity : String = ""
var _last_valid : bool = false


const BLOCK_ID: int = 6

const ENTITIES : Dictionary = {
	"barrel": {
		"tile_id": 1,
		"price": 10,
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
		"price": 10,
		"blocks_above": false,
	},
	"shelf": {
		"tile_id": 5,
		"price": 10,
		"blocks_above": true,
	},
}

const TILESET_SOURCE : int = 0
const EMPTY_TILE : int = -1
const INVALID_COLOR : Color = Color("Red")
const VALID_COLOR : Color = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_physics_process(false) # need gold but dont want to move charactser
	hold_controller.stepped.connect(_on_step)
	
	front_cam.make_current()
	current_layer = front_floor
	_update_bounds()
	current_tile = topleft
	update_price()
	
	await get_tree().process_frame
	_restore_entities_to_tilemap()

# Switches to and from back and front room
func _switch_cam() -> void:
	if front_cam.is_current():
		switch_to_back()
	else:
		switch_to_front()
	reset_cursor()


func reset_cursor() -> void:
	preview_layer.erase_cell(current_tile)
	current_tile = topleft


func switch_to_back() -> void:
	back_cam.make_current()
	current_layer = back_floor
	_update_bounds()

func switch_to_front() -> void:
	front_cam.make_current()
	current_layer = front_floor
	current_entity_idx = SHELF_IDX
	current_entity = ENTITY_ORDER[current_entity_idx]
	update_price()
	_update_bounds()
	

func _update_bounds() -> void:
	var tiles : Array = current_layer.get_used_cells()
	topleft = tiles[0]
	botright = tiles[0]
	
	for tile:Vector2i in tiles:
		topleft = Vector2i(min(topleft.x, tile.x), min(topleft.y, tile.y))
		botright = Vector2i(max(botright.x, tile.x), max(botright.y, tile.y))


func move_cursor(dir_delta : Vector2i) -> void:
	var next : Vector2i = current_tile + dir_delta
	if next.x < topleft.x or next.x > botright.x:
		return
	if next.y < topleft.y or next.y > botright.y:
		return
	current_tile = next

func _on_step(dir: DirectionalHoldController.Direction)->void:
	match dir:
		hold_controller.Direction.LEFT:
			move_cursor(Vector2i.LEFT)
		hold_controller.Direction.RIGHT:
			move_cursor(Vector2i.RIGHT)
		hold_controller.Direction.UP:
			move_cursor(Vector2i.UP)
		hold_controller.Direction.DOWN:
			move_cursor(Vector2i.DOWN)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		hold_controller.stop_hold()
		_switch_cam()
	
	if event.is_action_pressed("interact"):
		hold_controller.stop_hold()
		_place()
	
	if event.is_action_pressed("ui_accept"):
		hold_controller.stop_hold()
		_cycle()
		
	if event.is_action_pressed("ui_cancel"):
		_menu()
		get_viewport().set_input_as_handled()
		
	handle_movement_input(event)
		

func handle_movement_input(event: InputEvent) -> void:
	for action : StringName in MOVE_ACTIONS:
		var dir : DirectionalHoldController.Direction = MOVE_ACTIONS[action]
		if event.is_action_pressed(action):
			hold_controller.start_hold(dir)
		if event.is_action_released(action):
			if hold_controller.holding_dir == dir:
				_continue_or_stop_movement()

func _continue_or_stop_movement()->void:
	for action: StringName in MOVE_ACTIONS:
		if Input.is_action_pressed(action):
			hold_controller.start_hold(MOVE_ACTIONS[action])
			return
	hold_controller.stop_hold()

func _place() -> void:
	if not done_loading:
		return

	if not can_place_entity(current_tile):
		return
	
	place_entity(current_tile)
	player.set_coins(-(entity_info().price))

func place_entity(tile: Vector2i) -> void:
	entity_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, entity_info().tile_id)
	
	if entity_info().blocks_above:
		entity_layer.set_cell(tile + Vector2i.UP, TILESET_SOURCE, Vector2i.ZERO, BLOCK_ID)
	preview_layer.erase_cell(tile)
	_save_tile()

func _cycle() -> void:
	if current_layer == front_floor:
		current_entity_idx = SHELF_IDX
	else:
		current_entity_idx = (current_entity_idx+1) % ENTITY_ORDER.size()
	
	current_entity = ENTITY_ORDER[current_entity_idx]
	update_price()

func update_price()->void:
	cost.text = str(-entity_info().price)

func _process(delta: float) -> void:
	update_preview()
	hold_controller.process(delta)

func update_preview()->void:
	var valid : bool = can_place_entity(current_tile)
	
	if _tile_state_unchanged(valid):
		return
	
	preview_layer.clear()
	draw_preview_tile(current_tile, valid)
	_update_tile_state(valid)

func _tile_state_unchanged(valid : bool) -> bool:
	return current_tile == _last_tile and current_entity == _last_entity and valid == _last_valid

func _update_tile_state(valid : bool) -> void:
	_last_entity = current_entity
	_last_tile = current_tile
	_last_valid = valid

func draw_preview_tile(tile: Vector2i, valid: bool) -> void:
	preview_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, entity_info().tile_id)
	preview_layer.modulate = VALID_COLOR if valid else INVALID_COLOR

func _save_tile() -> void:
	var local_coords: Vector2 = preview_layer.map_to_local(current_tile)
	var placed_entity:Entity = em.create_entity(current_entity)
	placed_entity.position = local_coords
	em.add_child(placed_entity)

func _empty_cell(layer: TileMapLayer, coords: Vector2i) -> bool:
	return layer.get_cell_source_id(coords) == EMPTY_TILE
	
func _restore_entities_to_tilemap()->void:
	for entity in em.get_children():
		if entity.is_in_group("entity"):
			_restore_tile(entity.entity_code, entity_layer.local_to_map(entity.position))
	done_loading = true

func _restore_tile(entity_code:String, tile: Vector2i)->void:
	entity_layer.set_cell(tile, TILESET_SOURCE, Vector2i.ZERO, ENTITIES[entity_code].tile_id)
	
	if entity_code == "shelf" or entity_code == "bed":
		entity_layer.set_cell(tile + Vector2i.UP, TILESET_SOURCE, Vector2i.ZERO, BLOCK_ID)
	

func can_place_entity(tile : Vector2i) -> bool:
	if not _empty_cell(entity_layer, tile):
		return false
	
	if not _empty_cell(counters, tile):
		return false
	
	if entity_info().blocks_above:
		var above : Vector2i = tile + Vector2i.UP
		if not _empty_cell(entity_layer, above):
			return false
	
	if entity_info().price > player.get_coins():
		return false
	
	return true

func _menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")
	

func entity_info() -> Dictionary:
	return ENTITIES[current_entity]

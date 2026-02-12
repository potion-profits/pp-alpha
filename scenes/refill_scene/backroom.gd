extends Node2D

## Handles the refill behavior in the backroom scene.
## 
## Includes functions to highlight the correct crate/barrel, move the
## selection left or right, basic scene manipulation functions, and a slightly 
## more complex input handling workflow to make moving the selection feel better.


@onready var em: EntityManager = $EntityManager	## Reference to entity manager
@onready var player: Player = $EntityManager/Player	## Reference to player
@onready var static_ui: CanvasLayer = $Static_UI	## reference to static ui
@onready var hold_controller: DirectionalHoldController = $DirectionalHoldController
@onready var current_layer: TileMapLayer = $BackRoom/BackroomFloors

# expected payload variables
var target: String 	## Entity currently highlighted as a string.
var cost: int		## The cost to refill target.
var type: String 	## Specifies additional information about what is being refilled (barrel color).

var current_tile : Vector2i
var current_entity : Entity
var next_entity : Entity

var topleft  : Vector2i
var botright : Vector2i

var locations : Array

const SELECTABLE_PRICES : Dictionary = {
	"empty_barrel":INF,
	"red_barrel":160,
	"blue_barrel": 250,
	"green_barrel": 340,
	"dark_barrel": 420,
	"crate": 80
}

const SELECTABLE : Array = ["crate", "barrel"]

func _ready()->void:
	player.set_physics_process(false) # need gold but dont want to move character
	hold_controller.stepped.connect(_on_step)
	_load_payload()
	await get_tree().process_frame
	_update_bounds()
	_find_init_target()
	_highlight_current()
	
# gets all the entities that are being targetted (barrels or crates)
func _find_init_target() -> void:
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code in SELECTABLE:
				if not current_entity:
					current_entity = child as Entity
					current_tile = current_layer.local_to_map(current_entity.position)
				locations.append(current_layer.local_to_map(child.position))


func _update_bounds() -> void:
	var tiles : Array = current_layer.get_used_cells()
	topleft = tiles[0]
	botright = tiles[0]
	
	for tile:Vector2i in tiles:
		topleft = Vector2i(min(topleft.x, tile.x), min(topleft.y, tile.y))
		botright = Vector2i(max(botright.x, tile.x), max(botright.y, tile.y))

## Calls the refill function on the selected target and reduces player coins by cost.
## Expects the target to have refill function
func refill()->void:
	if player.get_coins() >= cost:
		player.set_coins(-cost)
		#selectables[idx].refill(type)
	# currently, just boots you back to the menu, should be handled differently later
	if player.get_coins() < cost:
		print("ran out of money")
		await get_tree().process_frame
		menu()

func find_next_selectable(from: Vector2i, dir: Vector2i) -> Vector2i:
	
#	What I want here is:
		#Look for all entities to the dir from from 
		#calculate the closest with vectors, select that one
	#var min_dist : float = 1_000_000
	#for pos: Vector2i in locations:
		#if pos*dir < from*dir:
			#var dist: float = from.distance_to(pos)
			#if  dist < min_dist:
				#min_dist = dist
		
	
	var pos :Vector2i = from
	
	while true:
		pos += dir
		if not is_inside_grid(pos):
			return from
		
		if is_selectable(pos):
			return pos
	return Vector2i.ZERO

func is_inside_grid(pos: Vector2i) -> bool:
	if pos.x < topleft.x or pos.x > botright.x:
		return false
	if pos.y < topleft.y or pos.y > botright.y:
		return false
	
	return true
	
func is_selectable(pos: Vector2i) -> bool:
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code in SELECTABLE:
				if current_layer.local_to_map(child.position) == pos:
					next_entity = child as Entity
					return true
	return false

func _on_step(dir: DirectionalHoldController.Direction)->void:
	var delta : Vector2i = DirectionalHoldController.DIR_VECTORS.get(dir)
	if delta == null:
		return
	
	var next_tile : Vector2i = find_next_selectable(current_tile, delta)
	if next_tile == current_tile:
		return
	
	_unhighlight_current()
	current_tile = next_tile
	current_entity = next_entity
	_highlight_current()
	
func _unhighlight_current()->void:
	current_entity.un_highlight()

func _highlight_current()->void:
	print("highlighting noww")
	current_entity.highlight()

 # Handles input catagorized into pressing a direction, releasing a direction, 
 # or interacting to refil the target
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("interact"):
		refill()
	
	if event.is_action_pressed("ui_cancel"):
		menu()
		get_viewport().set_input_as_handled()
	
	hold_controller.handle_movement_input(event)

## Changes the scene to the town menu.[br][br]
## Currently does not do anything other than change the scene through 
## [method SceneManage.change_to]. Would like to implement some sort of 
## message or popup.
func menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

# gets the payload and unpacks it
func _load_payload()->void:
	var payload : Dictionary = SceneManager.get_payload()
	target = payload.get("target", "barrel")
	cost = payload.get("cost", null)
	type = payload.get("type", "red_barrel")

extends Node2D

## Handles the refill behavior in the backroom scene.
## 
## Includes functions to highlight the correct crate/barrel, move the
## selection left or right, basic scene manipulation functions, and a slightly 
## more complex input handling workflow to make moving the selection feel better.


@onready var em: EntityManager = $EntityManager	## Reference to entity manager
@onready var player: Player = $EntityManager/Player	## Reference to player
@onready var static_ui: CanvasLayer = $Static_UI	## reference to static ui
## Reference to smooth movement handler
@onready var hold_controller: DirectionalHoldController = $DirectionalHoldController 
## Reference to the tile map layer that 
@onready var current_layer: TileMapLayer = $BackRoom/BackroomFloors
## Reference to the price indicator on the UI
@onready var cost: Label = $Static_UI/HBoxContainer/Cost
## Reference to the texture preview on the UI
@onready var blank_texture: TextureRect = $Static_UI/HBoxContainer/BlankTexture


var current_entity : Entity ## The entity that is currently selected
var selectables : Array[Entity] ## Holds all the selectable entities in the scene

## Holds the unique entity codes for all the selectables
const SELECTABLE : Array = ["crate", "barrel"]
## Default price for saftey
const FALLBACK_PRICE : int = 500
## Has the prices for each type of refill
const SELECTABLE_PRICES : Dictionary = {
	"red_barrel":160,
	"blue_barrel": 250,
	"green_barrel": 340,
	"dark_barrel": 420,
	"crate": 80
}
## Maintains a consistent order of barrel types to cycle through
const BARREL_ORDER: Array = ["red_barrel", "blue_barrel", "green_barrel", "dark_barrel"]

## Holds the index of the currently cycled through barrel refill type; default to red
var current_barrel_idx : int = 0

func _ready()->void:
	player.set_physics_process(false) # need gold but dont want to move character
	
	## Connects the on step function to the movement handler
	hold_controller.stepped.connect(_on_step)
	
	## Needs to first load all the entities to be able to highlight them, 
	## so we wait a frame
	await get_tree().process_frame
	
	## get the initial entity (just the first one to be found)
	_find_init_target()
	## highlight the initial entity
	_highlight_current()
	## make UI reflect the selected highlight's refill
	update_ui()
	
# gets all the entities that are being targetted (barrels or crates) and 
# picks the first valid one to be the current target
func _find_init_target() -> void:
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code in SELECTABLE:
				# only set current_entity if one hasnt been set
				if not current_entity:
					current_entity = child as Entity
				# always append to selectables list
				selectables.append(child)

## Calls the refill function on the selected target and reduces player coins by cost.
## Expects the target to have refill function
func refill()->void:
	var price : int =  _get_cost()
	var coins : int = player.get_coins()
	
	# When cant afford, text goes red for 0.3s and then white again
	if coins < price:
		cost.modulate = Color("Red")
		await get_tree().create_timer(0.3).timeout
		cost.modulate = Color("White")
		return
	
	# When can afford, deduce price and refill target
	player.set_coins(-price)

	if current_entity.entity_code == "barrel":
		current_entity.refill(BARREL_ORDER[current_barrel_idx])
	else:
		current_entity.refill()

# changes the barrel selection index
func _cycle() -> void:
	# only cycle if currently on a barrel
	if current_entity.entity_code == "barrel":
		current_barrel_idx = (current_barrel_idx + 1) % len(BARREL_ORDER)
		update_ui() # updates ui accordingly

# returns the cost of the current entity
func _get_cost() -> int:
	var e_type: String = current_entity.entity_code
	if e_type == "crate":
		return SELECTABLE_PRICES.get(e_type, FALLBACK_PRICE)
	return SELECTABLE_PRICES.get(BARREL_ORDER[current_barrel_idx], FALLBACK_PRICE)

## Updates UI to reflect the current entity
func update_ui()->void:
	cost.text = str(-_get_cost()) # change the cost label
	
	# change the icon
	if current_entity.entity_code == "barrel":
		blank_texture.texture = current_entity.get_barrel_texture(BARREL_ORDER[current_barrel_idx])
	else:
		var atlas : AtlasTexture = AtlasTexture.new()
		atlas.atlas = current_entity.empty_crate.texture
		atlas.region = current_entity.empty_crate.region_rect
		blank_texture.texture = atlas

# Finds the closest selectable in the given direction and sets it to current
func find_next_selectable(dir: Vector2) -> Entity:
	var best_entity: Entity = current_entity
	var min_dist : float = INF
	var from : Vector2 = best_entity.position
	
	# calculates distance to each selectables
	for entity : Entity in selectables:
		var pos : Vector2 = entity.position
		var to_candidate : Vector2 = pos - from
		
		# if its the current, dont check
		if to_candidate == Vector2.ZERO:
			continue
		
		# check that its in the correct direction
		if dir.x > 0 and to_candidate.x <= 0:
			continue
		if dir.x < 0 and to_candidate.x >= 0:
			continue
		if dir.y > 0 and to_candidate.y <= 0:
			continue
		if dir.y < 0 and to_candidate.y >= 0:
			continue
		
		# prioritizes entities that are more on the x or y based on the given direction
		if dir.x != 0 and abs(to_candidate.y) > abs(to_candidate.x):
			continue
		if dir.y != 0 and abs(to_candidate.x) > abs(to_candidate.y):
			continue
		
		# gets the minimum of previous and current
		var dist := to_candidate.length()
		if dist < min_dist:
			min_dist = dist
			best_entity = entity
	
	return best_entity

# When direction signals a step, handle the step by moving the highlight in the
# given directions.
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
	
	# change the highlight
	_unhighlight_current()
	current_entity = next_entity
	_highlight_current()
	# update ui to new entity
	update_ui()
	
# removes the highlight from the current entity
func _unhighlight_current()->void:
	current_entity.un_highlight()

# highlights the current entity
func _highlight_current()->void:
	current_entity.highlight()

 # Handles input catagorized into pressing a direction, releasing a direction, 
 # or interacting to refil the target
func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("interact"):
		refill()
	
	if event.is_action_pressed("ui_cancel"):
		menu()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("inventory"):
		_cycle()
	
	hold_controller.handle_movement_input(event)

# on every frame, process the hold_controller
func _process(delta: float) -> void:
	hold_controller.process(delta)

## Changes the scene to the town menu.[br][br]
## Currently does not do anything other than change the scene through 
## [method SceneManage.change_to]. Would like to implement some sort of 
## message or popup.
func menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

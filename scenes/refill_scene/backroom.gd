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
@onready var cost: Label = $Static_UI/HBoxContainer/Cost
@onready var blank_texture: TextureRect = $Static_UI/HBoxContainer/BlankTexture

var current_entity : Entity

var selectables : Array[Entity]

const SELECTABLE : Array = ["crate", "barrel"]
const FALLBACK_PRICE : int = 500
const SELECTABLE_PRICES : Dictionary = {
	"empty_barrel":INF,
	"red_barrel":160,
	"blue_barrel": 250,
	"green_barrel": 340,
	"dark_barrel": 420,
	"crate": 80
}
const BARREL_ORDER: Array = ["red_barrel", "blue_barrel", "green_barrel", "dark_barrel"]
var current_barrel_idx : int = 0

func _ready()->void:
	player.set_physics_process(false) # need gold but dont want to move character
	hold_controller.stepped.connect(_on_step)
	await get_tree().process_frame
	_find_init_target()
	_highlight_current()
	update_price()
	
# gets all the entities that are being targetted (barrels or crates)
func _find_init_target() -> void:
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code in SELECTABLE:
				if not current_entity:
					current_entity = child as Entity
				selectables.append(child)

## Calls the refill function on the selected target and reduces player coins by cost.
## Expects the target to have refill function
func refill()->void:
	var price : int =  _get_cost()
	var coins : int = player.get_coins()
	
	if coins < price:
		cost.modulate = Color("Red")
		await get_tree().create_timer(0.3).timeout
		cost.modulate = Color("White")
		return
		
	player.set_coins(-price)
	
	if current_entity.entity_code == "barrel":
		current_entity.refill(BARREL_ORDER[current_barrel_idx])
	else:
		current_entity.refill()


func _cycle() -> void:
	current_barrel_idx = (current_barrel_idx + 1) % len(BARREL_ORDER)
	update_price()

func _get_cost() -> int:
	var e_type: String = current_entity.entity_code
	if e_type == "crate":
		return SELECTABLE_PRICES.get(e_type, FALLBACK_PRICE)
	return SELECTABLE_PRICES.get(BARREL_ORDER[current_barrel_idx], FALLBACK_PRICE)

func update_price()->void:
	cost.text = str(-_get_cost())
	if current_entity.entity_code == "barrel":
		blank_texture.texture = current_entity.get_barrel_texture(BARREL_ORDER[current_barrel_idx])
	else:
		var atlas : AtlasTexture = AtlasTexture.new()
		atlas.atlas = current_entity.full_crate.texture
		atlas.region = current_entity.full_crate.region_rect
		blank_texture.texture = atlas
		
func find_next_selectable(dir: Vector2) -> Entity:
	var best_entity: Entity = current_entity
	var min_dist : float = INF
	var from : Vector2 = current_layer.local_to_map(best_entity.position)
	for entity : Entity in selectables:
		var pos : Vector2 = current_layer.local_to_map(entity.position)
		var to_candidate : Vector2 = pos - from
		if to_candidate == Vector2.ZERO:
			continue
		
		if dir.x > 0 and to_candidate.x <= 0:
			continue
		if dir.x < 0 and to_candidate.x >= 0:
			continue
		if dir.y > 0 and to_candidate.y <= 0:
			continue
		if dir.y < 0 and to_candidate.y >= 0:
			continue
		
		if dir.x != 0 and abs(to_candidate.y) > abs(to_candidate.x):
			continue
		if dir.y != 0 and abs(to_candidate.x) > abs(to_candidate.y):
			continue
		
		var dist := to_candidate.length()
		if dist < min_dist:
			min_dist = dist
			best_entity = entity
	
	return best_entity

func _on_step(dir: DirectionalHoldController.Direction)->void:
	var delta : Vector2i = DirectionalHoldController.DIR_VECTORS.get(dir)
	if delta == null:
		return
	
	var next_entity : Entity = find_next_selectable(delta)
	if next_entity == current_entity:
		return
	
	_unhighlight_current()
	current_entity = next_entity
	_highlight_current()
	update_price()
	
func _unhighlight_current()->void:
	current_entity.un_highlight()

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

func _process(delta: float) -> void:
	hold_controller.process(delta)

## Changes the scene to the town menu.[br][br]
## Currently does not do anything other than change the scene through 
## [method SceneManage.change_to]. Would like to implement some sort of 
## message or popup.
func menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

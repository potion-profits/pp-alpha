extends Node2D

## Handles the refill behavior in the backroom scene.
## 
## Includes functions to highlight the correct crate/barrel, move the
## selection left or right, basic scene manipulation functions, and a slightly 
## more complex input handling workflow to make moving the selection feel better.


@onready var em: EntityManager = $EntityManager	## Reference to entity manager
@onready var player: Player = $EntityManager/Player	## Reference to player
@onready var static_ui: CanvasLayer = $Static_UI	## reference to static ui

# expected payload variables
var target: String 	## Entity currently highlighted as a string.
var cost: int		## The cost to refill target.
var type: String 	## Specifies additional information about what is being refilled (barrel color).

var holding_dir : Direction = Direction.NONE ## Tells what direction is being held.

## All possible directions the selection can move & none for when it should not move.
enum Direction{
	NONE,
	LEFT,
	RIGHT,
	UP,		# not used yet but will likely be useful when on grid
	DOWN	# not used yet but will likely be useful when on grid
}

# array and index of entities to select (barrels or crates for now)
var selectables: Array = [] ## Holds all the possible targets.
var idx: int = 0 ## The index for the currently selected target. 

# delays for moving through selections
var first_delay: float = 0.3	## Threshold to start moving after initially holding.
var repeat_delay: float = 0.1	## Threshold to continue moving while holding.
var hold_time: float = 0.0	## Time [member holding_dir] has been held since last move.

# switch for repeat delay toggle
var repeat : bool = false ## Flag for handling moving while holding

func _ready()->void:
	player.set_physics_process(false) # need gold but dont want to move character
	
	# should likely go in scene manager
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn") 
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	await get_tree().process_frame
	
	# gets the payload and unpacks it
	var payload : Dictionary = SceneManager.get_payload()
	target = payload.get("target", "barrel")
	cost = payload.get("cost", null)
	type = payload.get("type", "red_barrel")
	
	# gets all the entities that are being targetted (barrels or crates)
	if em:
		for child in em.get_children():
			if child is Entity and child.entity_code == target:
				selectables.append(child)
	
	# if there are selecatable targets, highlight the first one
	if not selectables.is_empty():
		selectables[idx].highlight()

## Calls the refill function on the selected target and reduces player coins by cost.
## Expects the target to have refill function
func refill()->void:
	if player.get_coins() >= cost:
		player.set_coins(-cost)
		selectables[idx].refill(type)
	# currently, just boots you back to the menu, should be handled differently later
	if player.get_coins() < cost:
		print("ran out of money")
		await get_tree().process_frame
		menu()

#
# Move functions to select different targets but I havent implemented down or up because 2d array
#

## Selects the target to the right of the current target
func move_right()->void:
	selectables[idx].un_highlight()
	idx = (idx+1)%selectables.size()
	selectables[idx].highlight()

## Selects the target to the left of the current target
func move_left()->void:
	selectables[idx].un_highlight()
	idx = (idx-1)%selectables.size()
	selectables[idx].highlight()

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
			move_left()
		Direction.RIGHT:
			move_right()
		Direction.UP:
			pass
		Direction.DOWN:
			pass

 # Handles input catagorized into pressing a direction, releasing a direction, 
 # or interacting to refil the target
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left"):
		_start_hold(Direction.LEFT)
		
	if event.is_action_pressed("move_right"):
		_start_hold(Direction.RIGHT)
	
	if event.is_action_released("move_left") and holding_dir == Direction.LEFT:
		_stop_hold()
	
	if event.is_action_released("move_right") and holding_dir == Direction.RIGHT:
		_stop_hold()
	
	if event.is_action_pressed("interact"):
		_stop_hold()
		refill()
	
	if event.is_action_pressed("ui_cancel"):
		menu()
		get_viewport().set_input_as_handled()

# Handles holding a direction
func _process(delta: float) -> void:
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

## Changes the scene to the town menu.[br][br]
## Currently does not do anything other than change the scene through 
## [method SceneManage.change_to]. Would like to implement some sort of 
## message or popup.
func menu()->void:
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

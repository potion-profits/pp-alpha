# tutorial.gd — attached to tutorial.tscn CanvasLayer root
extends CanvasLayer

## Tutorial UI nodes
@onready var dialogue_label: Label = $DialogueContainer/DialoguePanel/MarginContainer/ScrollContainer/DialogueLabel
@onready var character_portrait: TextureRect = $DialogueContainer/DialoguePanel/TutorialCatPortrait

## Indicator of which tutorial step player is on
var current_step_index: int = 0
## Holds tutorial steps
var tutorial_steps: Array = []
## Bool for whether player can advance to next tutorial step
var can_advance: bool = true

## Scene references set by setup()
var tutorial_character: StaticBody2D
var tutorial_markers: Node

## Backroom boundary for room detection
var backroom_bottom: float = 0.0

signal tutorial_complete


func _process(_delta: float) -> void:
	if not GameManager.tutorial_completed:
		check_process()


func _input(event: InputEvent) -> void:
	if not GameManager.tutorial_completed:
		on_input(event)


func setup(scene_root: Node) -> void:
	tutorial_character = scene_root.get_node("EntityManager/TutorialCat")
	tutorial_markers = scene_root.get_node("TutorialMarkers")
	backroom_bottom = scene_root.get_node("BackRoom/BackRoomEdges/BottomRight").global_position.y

	var em := scene_root.get_node("EntityManager")

	for node in em.get_children():
		if node is Cauldron:
			if node.has_signal("mixing_potion") and not node.mixing_potion.is_connected(_on_tutorial_event.bind("potion_mixed")):
				node.mixing_potion.connect(_on_tutorial_event.bind("potion_mixed"))

			if node.has_node("MixTimer") and not node.get_node("MixTimer").timeout.is_connected(_on_tutorial_event.bind("potion_ready")):
				node.get_node("MixTimer").timeout.connect(_on_tutorial_event.bind("potion_ready"))

			if node.has_signal("potion_collected") and not node.potion_collected.is_connected(_on_tutorial_event.bind("potion_grabbed")):
				node.potion_collected.connect(_on_tutorial_event.bind("potion_grabbed"))

		elif node is Crate:
			if node.has_signal("bottle_taken") and not node.bottle_taken.is_connected(_on_tutorial_event.bind("bottle_grabbed")):
				node.bottle_taken.connect(_on_tutorial_event.bind("bottle_grabbed"))

		elif node is Barrel:
			if node.has_signal("ingredients_taken") and not node.ingredients_taken.is_connected(_on_tutorial_event.bind("ingredients_grabbed")):
				node.ingredients_taken.connect(_on_tutorial_event.bind("ingredients_grabbed"))

		elif node is Shelf:
			if node.has_signal("shelf_opened") and not node.shelf_opened.is_connected(_on_tutorial_event.bind("shelf_opened")):
				node.shelf_opened.connect(_on_tutorial_event.bind("shelf_opened"))

			if node.inv and node.inv.has_signal("update") and not node.inv.update.is_connected(_on_tutorial_event.bind("item_stocked")):
				node.inv.update.connect(_on_tutorial_event.bind("item_stocked"))

			if node.has_signal("shelf_closed") and not node.shelf_closed.is_connected(_on_tutorial_event.bind("shelf_closed")):
				node.shelf_closed.connect(_on_tutorial_event.bind("shelf_closed"))

## Starts tutorial
func start(steps: Array) -> void:
	TimeManager.set_process(false)
	tutorial_steps = steps
	current_step_index = 0
	can_advance = true
	visible = true
	show_current_step()
	
	# Initial Step, play Dialogue SFX
	SFXManager.play_dialogue("cat")


## Enact all needed actions for current tutorial step
func show_current_step() -> void:
	if current_step_index >= tutorial_steps.size():
		tutorial_complete.emit()
		GameManager.tutorial_completed = true
		return

	var step: Dictionary = tutorial_steps[current_step_index]

	# Skip backroom/frontroom steps if player is already there
	if step.get("id") == "go_backroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y <= backroom_bottom:
			advance("entered_backroom")
			return
	elif step.get("id") == "go_frontroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y > backroom_bottom:
			advance("entered_frontroom")
			return

	if step.has("marker") and tutorial_markers:
		var marker: Marker2D = tutorial_markers.get_node_or_null(step["marker"])
		if marker and is_instance_valid(tutorial_character):
			tutorial_character.global_position = marker.global_position
			tutorial_character.visible = true

	dialogue_label.text = step.get("text", "")


## Advance to next tutorial step
func advance(trigger: String = "") -> void:
	if not can_advance:
		return

	var current_step: Dictionary = tutorial_steps[current_step_index]

	var cd: float = current_step.get("cooldown", 0.0)
	if cd > 0.0:
		can_advance = false
		await get_tree().create_timer(cd).timeout
		current_step = tutorial_steps[current_step_index]

	if current_step.has("wait_for"):
		if trigger != current_step["wait_for"]:
			can_advance = true
			return
	# Per Step, play Dialogue SFX
	SFXManager.play_dialogue("cat")
	can_advance = false
	current_step_index += 1
	show_current_step()
	can_advance = true


## Grab current step from json
func get_current_step() -> Dictionary:
	if current_step_index < tutorial_steps.size():
		return tutorial_steps[current_step_index]
	return {}


## Disable all Tutorial UI items upon tutorial completion
func on_complete() -> void:
	visible = false
	character_portrait.visible = false
	if is_instance_valid(tutorial_character):
		if tutorial_character.has_node("SpeechBubble"):
			tutorial_character.get_node("SpeechBubble").visible = false
	set_process(false)
	set_process_input(false)
	TimeManager.set_process(true)
	TimeManager.time = 0.0
	GameManager.tutorial_completed = true


## Tracking player and input for tutorial advancement
func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or \
	   event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		_on_tutorial_event("player_moved")


func check_process() -> void:
	var current_step: Dictionary = get_current_step()
	if current_step.is_empty():
		return

	match current_step.get("id", ""):
		"go_backroom":
			var player: Player = get_tree().get_first_node_in_group("player")
			if player and player.global_position.y <= backroom_bottom:
				advance("entered_backroom")
		"go_frontroom":
			var player: Player = get_tree().get_first_node_in_group("player")
			if player and player.global_position.y > backroom_bottom:
				advance("entered_frontroom")
		_:
			pass


# Single unified handler for all tutorial gameplay signals
func _on_tutorial_event(trigger: String) -> void:
	# If the current step expects this trigger, advance.
	if get_current_step().get("wait_for") == trigger:
		advance(trigger)

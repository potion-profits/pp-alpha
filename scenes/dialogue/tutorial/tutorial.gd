# tutorial.gd — attached to tutorial.tscn CanvasLayer root
extends CanvasLayer

## Tutorial UI nodes
@onready var dialogue_label: Label = $DialogueContainer/DialoguePanel/MarginContainer/DialogueLabel
@onready var character_portrait: TextureRect = $DialogueContainer/DialoguePanel/TutorialCatPortrait

## Indicator of which tutorial step player is on
var current_step_index: int = 0
## Holds tutorial steps
var tutorial_steps: Array = []
## Bool for whether player can advance to next tutorial step
var can_advance: bool = true

## Bool for player interaction with tutorial item
var player_has_interacted: bool = false
## To track proper tutorial interaction with shelf
var shelf_item_count_before: int = 0
## Player first slot check
var selected_slot : InvSlot

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
	
	for cauldron: Node2D in get_tree().get_nodes_in_group("tutorial_cauldron"):
		if cauldron.has_node("MixTimer"):
			cauldron.get_node("MixTimer").timeout.connect(on_cauldron_done)

## Starts tutorial
func start(steps: Array) -> void:
	tutorial_steps = steps
	current_step_index = 0
	can_advance = true
	visible = true
	show_current_step()

## Enact all needed actions for current tutorial step
func show_current_step() -> void:
	if current_step_index >= tutorial_steps.size():
		tutorial_complete.emit()
		GameManager.tutorial_completed = true
		return

	var step: Dictionary = tutorial_steps[current_step_index]

	# Skip backroom/frontroom steps if player is already there
	if step["id"] == "go_backroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y <= backroom_bottom:
			advance("entered_backroom")
			return
	elif step["id"] == "go_frontroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y > backroom_bottom:
			advance("entered_frontroom")
			return

	if step.has("marker") and tutorial_markers:
		var marker: Marker2D = tutorial_markers.get_node_or_null(step["marker"])
		if marker:
			tutorial_character.global_position = marker.global_position
			tutorial_character.visible = true

	DialogueManager.show_text(step["text"], step.get("speaker", ""))
	dialogue_label.text = step["text"]

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

## Tracking player and input for tutorial advancement
func on_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or \
	   event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		var step: Dictionary = get_current_step()
		if step.get("wait_for") == "player_moved":
			advance("player_moved")

	if not player_has_interacted:
		if event.is_action_pressed("interact"):
			check_item_interaction()

## Check on proper player interaction according to relevant tutorial step
func check_item_interaction() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var current_step: Dictionary = get_current_step()
	if current_step.is_empty():
		return
	var step_id: String = current_step["id"]

	if step_id == "grab_bottle":
		for crate: Node2D in get_tree().get_nodes_in_group("tutorial_crate"):
			if player.global_position.distance_to(crate.global_position) < 50:
				await get_tree().process_frame
				selected_slot = player.get_selected_slot()
				if selected_slot and selected_slot.item:
					if selected_slot.item.texture_code == "item_empty_bottle":
						advance("bottle_grabbed")
				return

	elif step_id == "mix_potion":
		for cauldron: Node2D in get_tree().get_nodes_in_group("tutorial_cauldron"):
			if player.global_position.distance_to(cauldron.global_position) < 50:
				await get_tree().process_frame
				if cauldron.mixing or (cauldron.inv.slots[0].item and cauldron.inv.slots[0].item.mixable):
					advance("potion_mixed")
				return

	elif step_id == "grab_potion":
		for cauldron: Node2D in get_tree().get_nodes_in_group("tutorial_cauldron"):
			if player.global_position.distance_to(cauldron.global_position) < 50:
				await get_tree().process_frame
				var slot: InvSlot = player.get_selected_slot()
				if slot and slot.item and slot.item.sellable:
					advance("potion_grabbed")
				return

	elif step_id == "go_to_shelf":
		for shelf: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
			if player.global_position.distance_to(shelf.global_position) < 50:
				shelf_item_count_before = 0
				for shelf_node: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
					if "inv" in shelf_node and shelf_node.inv:
						for slot: InvSlot in shelf_node.inv.slots:
							if slot.item and slot.item.sellable:
								shelf_item_count_before += 1
				advance("shelf_opened")
				return

func on_cauldron_done() -> void:
	if get_current_step().get("id") == "wait_brewing":
		advance("potion_ready")

func check_process() -> void:
	var current_step: Dictionary = get_current_step()
	if current_step.is_empty():
		return

	if current_step["id"] == "go_backroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y <= backroom_bottom:
			advance("entered_backroom")

	elif current_step["id"] == "go_frontroom":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.y > backroom_bottom:
			advance("entered_frontroom")

	elif current_step["id"] == "get_ingredients":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player:
			var slot: InvSlot = player.get_selected_slot()
			if slot and slot.item and slot.item.texture_code == "item_red_potion":
				advance("ingredients_grabbed")

	elif current_step["id"] == "stock_shelf":
		var current_count: int = 0
		for shelf: Node2D in get_tree().get_nodes_in_group("tutorial_shelf"):
			if "inv" in shelf and shelf.inv:
				for slot: InvSlot in shelf.inv.slots:
					if slot.item and slot.item.sellable:
						current_count += 1
		if current_count > shelf_item_count_before:
			advance("item_stocked")

	elif current_step["id"] == "close_shelf":
		var player: Player = get_tree().get_first_node_in_group("player")
		if player and player.can_move:
			advance("shelf_closed")

# dialogue_ui.gd — attach to dialogue_ui.tscn CanvasLayer root
extends CanvasLayer

## Reference to the label that displays dialogue text
@onready var dialogue_label: Label = $DialogueContainer/DialoguePanel/MarginContainer/ScrollContainer/VBoxContainer/DialogueLabel
## Container that holds dynamically created choice buttons
@onready var choice_container: VBoxContainer = $DialogueContainer/DialoguePanel/MarginContainer/ScrollContainer/VBoxContainer/ChoiceContainer

## Key for the current dialogue JSON file (like "casino", "supply_shop")
var current_file_key: String = ""
## ID of the currently displayed dialogue node
var current_node_id: String = ""
## Whether the dialogue UI is currently active and processing input
var is_active: bool = false
## Whether the UI is waiting for player to dismiss a terminal (no choices) node
var waiting_for_dismiss: bool = false
## Holds the current set of choice dictionaries from the dialogue node
var choice_list: Array = []

## Emitted when the dialogue is fully closed
signal dialogue_ended
## Emitted when a choice with an "action" field is selected
signal action_triggered(action: String, data: Dictionary)

func _ready() -> void:
	visible = false

## Opens the dialogue UI starting at the given dialogue node
func open(file_key: String, dialogue_id: String) -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	var last_dir: String = player.last_dir
	var player_idle_dir: String = "idle_" + last_dir
	
	if last_dir:
		player.animated_sprite.play(player_idle_dir)
	
	current_file_key = file_key
	current_node_id = dialogue_id
	is_active = true
	waiting_for_dismiss = false
	visible = true
	show_node(dialogue_id)
	DialogueManager.dialogue_open = true

## Displays a dialogue node by ID — sets text and creates choice buttons
func show_node(dialogue_id: String) -> void:
	clear_choices()
	waiting_for_dismiss = false

	var node: Dictionary = DialogueManager.get_dialogue(current_file_key, dialogue_id)
	if node.is_empty():
		close()
		return

	current_node_id = dialogue_id
	var choices: Array = node.get("choices", [])
	choice_list = choices

	dialogue_label.text = node.get("text", "")

	# If no choices, wait for player to dismiss with interact key
	if choices.is_empty():
		waiting_for_dismiss = true
	else:
		# Create numbered choice buttons
		for i in range(choices.size()):
			var button: Button = Button.new()
			button.text = "%d. %s" % [i + 1, choices[i].get("label", "...")]
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(select_choice.bind(i))
			choice_container.add_child(button)

## Sets the dialogue label text directly without choices — used by scene scripts
## for custom UI states (e.g. exchange menu text)
func show_text(text: String) -> void:
	clear_choices()
	dialogue_label.text = text
	waiting_for_dismiss = false

## Handles a choice being selected by index (from button click or number key)
func select_choice(index: int) -> void:
	if index < 0 or index >= choice_list.size():
		return
	var choice: Dictionary = choice_list[index]
	var action: String = choice.get("action", "")
	var next_id: Variant = choice.get("next", null)

	# If no next node, close dialogue and emit action if present
	if next_id == null or next_id == "":
		if action != "":
			action_triggered.emit(action, choice)
		else:
			close()
	# If there is a next node, emit action and continue to next dialogue
	else:
		if action != "":
			action_triggered.emit(action, choice)
		show_node(next_id)

## Removes all choice buttons from the container
func clear_choices() -> void:
	choice_list = []
	for child: Node in choice_container.get_children():
		choice_container.remove_child(child)
		child.queue_free()

## Closes the dialogue UI and emits dialogue_ended
func close() -> void:
	clear_choices()
	visible = false
	is_active = false
	waiting_for_dismiss = false
	dialogue_ended.emit()

## Handles keyboard input selecting choices
func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if not visible:
		return

	# Skip input handling when no choices and not waiting to dismiss
	# (e.g. when a scene-specific UI like exchange is showing)
	if choice_list.is_empty() and not waiting_for_dismiss:
		return

	# Dismiss terminal dialogue nodes with interact key
	if waiting_for_dismiss and event.is_action_pressed("interact"):
		close()
		get_viewport().set_input_as_handled()
		return

	# Number keys 1-9 select corresponding choice
	if choice_list.size() > 0 and event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < choice_list.size() and index < 9:
			select_choice(index)
			get_viewport().set_input_as_handled()

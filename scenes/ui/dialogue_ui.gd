# dialogue_ui.gd — attach to dialogue_ui.tscn CanvasLayer root
extends CanvasLayer

@onready var dialogue_label: Label = $DialogueContainer/DialoguePanel/MarginContainer/ScrollContainer/VBoxContainer/DialogueLabel
@onready var choice_container: VBoxContainer = $DialogueContainer/DialoguePanel/MarginContainer/ScrollContainer/VBoxContainer/ChoiceContainer

var current_file_key: String = ""
var current_node_id: String = ""
var is_active: bool = false
var waiting_for_dismiss: bool = false
var choice_list: Array = []

signal dialogue_ended
signal action_triggered(action: String, data: Dictionary)

func _ready() -> void:
	visible = false
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func open(file_key: String, dialogue_id: String) -> void:
	current_file_key = file_key
	current_node_id = dialogue_id
	is_active = true
	waiting_for_dismiss = false
	visible = true
	show_node(dialogue_id)

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
	DialogueManager.show_text(node.get("text", ""), node.get("speaker", ""))

	if choices.is_empty():
		waiting_for_dismiss = true
	else:
		for i in range(choices.size()):
			var button: Button = Button.new()
			button.text = "%d. %s" % [i + 1, choices[i].get("label", "...")]
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.pressed.connect(select_choice.bind(i))
			choice_container.add_child(button)

func show_text(text: String) -> void:
	clear_choices()
	dialogue_label.text = text
	waiting_for_dismiss = false

func select_choice(index: int) -> void:
	if index < 0 or index >= choice_list.size():
		return
	var choice: Dictionary = choice_list[index]
	var action: String = choice.get("action", "")
	var next_id: Variant = choice.get("next", null)

	if next_id == null or next_id == "":
		if action != "":
			action_triggered.emit(action, choice)
		else:
			close()
	else:
		if action != "":
			action_triggered.emit(action, choice)
		show_node(next_id)

func clear_choices() -> void:
	choice_list = []
	for child: Node in choice_container.get_children():
		choice_container.remove_child(child)
		child.queue_free()

func close() -> void:
	clear_choices()
	visible = false
	is_active = false
	waiting_for_dismiss = false
	dialogue_ended.emit()

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	if not visible:
		return

	if choice_list.is_empty() and not waiting_for_dismiss:
		return

	if waiting_for_dismiss and event.is_action_pressed("interact"):
		close()
		get_viewport().set_input_as_handled()
		return

	if choice_list.size() > 0 and event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < choice_list.size() and index < 9:
			select_choice(index)
			get_viewport().set_input_as_handled()

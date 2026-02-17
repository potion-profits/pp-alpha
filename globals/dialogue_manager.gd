# DialogueManager.gd (autoload)
extends Node

# Holds JSON
var dialogue_data: Dictionary = {}
# Indicates which step of tutorial player is on
var current_step_index: int = 0
# Array of all tutorial steps
var tutorial_steps: Array = []
# Checks if all conditions to reach next tutorial step is cleared
var can_advance: bool = true
# Default cooldown time for automatic advancement of certain steps
var cooldown_time: float = 1.5

signal dialogue_shown(text: String)
signal tutorial_complete

func _ready() -> void:
	load_dialogue_data()

#
func load_dialogue_data() -> void:
	var file: FileAccess = FileAccess.open("res://assets/dialogue/dialogues.json", FileAccess.READ)
	if file:
		var json_string: String = file.get_as_text()
		dialogue_data = JSON.parse_string(json_string)
		tutorial_steps = dialogue_data.get("tutorial", [])
		print(">>> Loaded tutorial_steps, count:", tutorial_steps.size())
	else:
		print(">>> ERROR: Could not open dialogues.json")

func start_tutorial() -> void:
	print(">>> DialogueManager.start_tutorial() called")
	current_step_index = 0
	show_current_step()

func show_current_step() -> void:
	if current_step_index >= tutorial_steps.size():
		tutorial_complete.emit()
		GameManager.tutorial_completed = true
		return
	
	var step: Dictionary = tutorial_steps[current_step_index]
	print(">>> About to emit dialogue_shown with text:", step.get("text", "NO TEXT FOUND"))
	dialogue_shown.emit(step["text"])
	print(">>> Signal emitted")

func advance_tutorial(trigger: String = "") -> void:
	if not can_advance:
		return  # Ignore if on cooldown
	
	print(">>> advance_tutorial called with trigger:", trigger)
	var current_step: Dictionary = tutorial_steps[current_step_index]
	print(">>> Current step wait_for:", current_step.get("wait_for", "none"))
	
	# Only add timer if applicable
	if current_step.has("cooldown"):
		cooldown_time = current_step["cooldown"] 
		can_advance = false
		await get_tree().create_timer(cooldown_time).timeout
	else:
		cooldown_time = 0.0
		
	# Check if we need to wait for something
	if current_step.has("wait_for"):
		if trigger == current_step["wait_for"]:
			print(">>> Trigger matches! Advancing...")
			current_step_index += 1
			show_current_step()
		else:
			print(">>> Trigger doesn't match, not advancing")
	else:
		# Auto-advance
		print(">>> No wait_for, auto-advancing")
		can_advance = false  # start cooldown
		current_step_index += 1
		show_current_step()
		await get_tree().create_timer(cooldown_time).timeout
		can_advance = true  # end cooldown

func show_dialogue(dialogue_id: String) -> Dictionary:
	var dialogue: Dictionary = dialogue_data["dialogues"].get(dialogue_id, {})
	if dialogue:
		dialogue_shown.emit(dialogue["text"])
	return dialogue

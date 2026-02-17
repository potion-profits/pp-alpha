extends Control
class_name HotkeyRebindButton

@onready var label: Label = $HBoxContainer/Label
@onready var button: Button = $HBoxContainer/Button
@onready var key_prompt: Panel = $HBoxContainer/Button/Panel

# Action names are defined the project settings under input_map
# Exported to button field 
@export var action_name: String = ""

var action_to_display: Dictionary = {
	"move_left": "MOVE LEFT",
	"move_right": "MOVE RIGHT",
	"move_up": "MOVE UP",
	"move_down": "MOVE DOWN",
	"interact": "INTERACT",
	"dash": "DASH",
	"slot_1": "SLOT 1",
	"slot_2": "SLOT 2",
	"slot_3": "SLOT 3",
	"slot_4": "SLOT 4",
	"slot_5": "SLOT 5"
}

func _ready() -> void:
	# Ignores other input handles
	# prevents accidental rebinding
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	load_keybind()

# From loaded file, assign each action a key
func load_keybind() -> void:
	rebind_action_key(SettingDataContainer.get_keybind(action_name))

func set_action_name() -> void:
	label.text = "Unassigned"
	if action_to_display.get(action_name):
		label.text = action_to_display.get(action_name)

func set_text_for_key() -> void:
	# returns array of 1 item
	var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)
	var action_event:InputEvent = action_events[0]
	# Map action to keycode
	var action_keycode: String = OS.get_keycode_string(action_event.physical_keycode)
	button.text = "%s" % action_keycode

func _on_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		key_prompt.visible = true
		# Listen for any key
		set_process_unhandled_key_input(true)
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				# stops any other button to toggled (only one toggled at a time
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		# reset states once untoggled
		key_prompt.visible = false
		set_process_unhandled_key_input(false)
		for i in get_tree().get_nodes_in_group("hotkey_button"):
			if i.action_name != self.action_name:
				# stops any other button to toggled (only one toggled at a time
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		set_text_for_key()

## Runs when unhandled key is pressed
func _unhandled_key_input(event: InputEvent) -> void:
	# Untoggles button once new key assigned
	rebind_action_key(event)
	button.button_pressed = false

func rebind_action_key(event: InputEvent) -> void:
	# Erase current event
	InputMap.action_erase_events(action_name)
	# Rebind the pressed key to new action
	InputMap.action_add_event(action_name, event)
	
	# Signal data container for saving data
	SettingDataContainer.set_keybind(action_name, event)
	
	# Can now listen to all inputs
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()


# TODO: Logic check to ensure you dont have conflicting keys

# TODO: Reset to default

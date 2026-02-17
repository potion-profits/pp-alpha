extends Node

## Default Setting values
@onready var keybind_resource : KeybindContainer = preload("res://scenes/ui/default_keybinds.tres")

var tooltip_enabled: bool = true
var window_mode_index: int = 0
var resolution_mode_index: int = 0
# Volumes stored are db values
var master_volume: float = 0.0
var music_volume: float = 0.0
var sfx_volume: float = 0.0

## Save loaded data
var loaded_data: Dictionary = {}

var keybind_mapping: Dictionary = {
	
}

func _ready() -> void:
	handle_signals()
	create_storage_dict()

# Temporarly saving all hotkeys
func create_storage_dict() -> Dictionary:
	var setting_dict: Dictionary = {
		"tooltip_enabled": tooltip_enabled,
		"window_mode_index": window_mode_index,
		"resolution_mode_index": resolution_mode_index,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"move_left": InputMap.action_get_events("move_left"),
		"move_right": InputMap.action_get_events("move_right"),
		"keybinds": create_keybind_dict()
	}
	return setting_dict

## Will be created within the settings storage dictionary (nested dict)
func create_keybind_dict() -> Dictionary:
	# Map from keybind container resource (custom keys, defaults already set)
	var keybind_dict: Dictionary = {
		keybind_resource.MOVE_LEFT : keybind_resource.move_left_key.physical_keycode,
		keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key.physical_keycode,
		keybind_resource.MOVE_UP : keybind_resource.move_up_key.physical_keycode,
		keybind_resource.MOVE_DOWN : keybind_resource.move_down_key.physical_keycode,
		keybind_resource.INTERACT : keybind_resource.interact_key.physical_keycode,
		keybind_resource.DASH : keybind_resource.dash_key.physical_keycode,
		keybind_resource.SLOT_1 : keybind_resource.slot_1_key.physical_keycode,
		keybind_resource.SLOT_2 : keybind_resource.slot_2_key.physical_keycode,
		keybind_resource.SLOT_3 : keybind_resource.slot_3_key.physical_keycode,
		keybind_resource.SLOT_4 : keybind_resource.slot_4_key.physical_keycode,
		keybind_resource.SLOT_5 : keybind_resource.slot_5_key.physical_keycode,
	}
	return keybind_dict

#TODO From vid, extra getters to validate and return defaults for missing values (create resource file)

# Signal related data to load (parameter of settings data loaded in)
# Called once settings config file detected from SaveManager
func on_load_settings_data(data_dict: Dictionary) -> void:
	if !data_dict:
		return
	loaded_data = data_dict.get("data")
	# Call each setting function with loaded dict( everything except keybinds)
	on_tooltip_enabled(loaded_data.get("tooltip_enabled"))
	on_window_selected(loaded_data.get("window_mode_index"))
	on_resolution_selected(loaded_data.get("resolution_mode_index"))
	on_master_vol_set(loaded_data.get("master_volume"))
	on_music_vol_set(loaded_data.get("music_volume"))
	on_sfx_vol_set(loaded_data.get("sfx_volume"))
	on_keybinds_loaded(loaded_data.get("keybinds"))

# Signal related data to set
func on_tooltip_enabled(enabled: bool) -> void:
	tooltip_enabled = enabled

func on_window_selected(index: int) -> void:
	window_mode_index = index

func on_resolution_selected(index: int) -> void:
	resolution_mode_index = index

func on_master_vol_set(value: float) -> void:
	master_volume = value

func on_music_vol_set(value: float) -> void:
	music_volume = value

func on_sfx_vol_set(value: float) -> void:
	sfx_volume = value

# Setter functions for rebinding keys
func set_keybind(action: String, event: InputEventKey) -> void:
	match action:
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.MOVE_UP:
			keybind_resource.move_up_key = event
		keybind_resource.MOVE_DOWN:
			keybind_resource.move_down_key = event
		keybind_resource.INTERACT:
			keybind_resource.interact_key = event
		keybind_resource.DASH:
			keybind_resource.dash_key = event
		keybind_resource.SLOT_1:
			keybind_resource.slot_1_key = event
		keybind_resource.SLOT_2:
			keybind_resource.slot_2_key = event
		keybind_resource.SLOT_3:
			keybind_resource.slot_3_key = event
		keybind_resource.SLOT_4:
			keybind_resource.slot_4_key = event
		keybind_resource.SLOT_5:
			keybind_resource.slot_5_key = event

# I DO NOT LIKE THIS AT ALL (Works but ugly), fuck ass tutorial
func on_keybinds_loaded(data: Dictionary) -> void:
	var loaded_move_left : InputEventKey = InputEventKey.new()
	var loaded_move_right : InputEventKey = InputEventKey.new()
	var loaded_move_up : InputEventKey = InputEventKey.new()
	var loaded_move_down: InputEventKey = InputEventKey.new()
	var loaded_interact : InputEventKey = InputEventKey.new()
	var loaded_dash : InputEventKey = InputEventKey.new()
	var loaded_slot_1 : InputEventKey = InputEventKey.new()
	var loaded_slot_2 : InputEventKey = InputEventKey.new()
	var loaded_slot_3 : InputEventKey = InputEventKey.new()
	var loaded_slot_4 : InputEventKey = InputEventKey.new()
	var loaded_slot_5 : InputEventKey = InputEventKey.new()
	
	print(type_string(typeof(data.move_left)))
	loaded_move_left.set_physical_keycode(data.move_left)
	loaded_move_right.set_physical_keycode(data.move_right)
	loaded_move_up.set_physical_keycode(data.move_up)
	loaded_move_down.set_physical_keycode(data.move_down)
	loaded_interact.set_physical_keycode(data.interact)
	loaded_dash.set_physical_keycode(data.sprint)
	loaded_slot_1.set_physical_keycode(data.slot_1)
	loaded_slot_2.set_physical_keycode(data.slot_2)
	loaded_slot_3.set_physical_keycode(data.slot_3)
	loaded_slot_4.set_physical_keycode(data.slot_4)
	loaded_slot_5.set_physical_keycode(data.slot_5)
	
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.move_up_key = loaded_move_up
	keybind_resource.move_down_key = loaded_move_down
	keybind_resource.interact_key = loaded_interact
	keybind_resource.dash_key = loaded_dash
	keybind_resource.slot_1_key = loaded_slot_1
	keybind_resource.slot_2_key = loaded_slot_2
	keybind_resource.slot_3_key = loaded_slot_3
	keybind_resource.slot_4_key = loaded_slot_4
	keybind_resource.slot_5_key = loaded_slot_5
	
	#for action_name in data.keys():
		#var event : InputEventKey = InputEventKey.new()
		#event.physical_keycode = int(data.get(action_name))
		## Add the new keybind
		#InputMap.action_add_event(action_name, event)

## Getter functions
func get_keybind(action: String):
	if !(loaded_data.has("keybinds")):
		# If not in save file, load in default data
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.MOVE_UP:
				return keybind_resource.DEFAULT_MOVE_UP_KEY
			keybind_resource.MOVE_DOWN:
				return keybind_resource.DEFAULT_MOVE_DOWN_KEY
			keybind_resource.INTERACT:
				return keybind_resource.DEFAULT_INTERACT_KEY
			keybind_resource.DASH:
				return keybind_resource.DEFAULT_DASH_KEY
			keybind_resource.SLOT_1:
				return keybind_resource.DEFAULT_SLOT_1_KEY
			keybind_resource.SLOT_2:
				return keybind_resource.DEFAULT_SLOT_2_KEY
			keybind_resource.SLOT_3:
				return keybind_resource.DEFAULT_SLOT_3_KEY
			keybind_resource.SLOT_4:
				return keybind_resource.DEFAULT_SLOT_4_KEY
			keybind_resource.SLOT_5:
				return keybind_resource.DEFAULT_SLOT_5_KEY
	else:
		# If exists, set from file
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.MOVE_UP:
				return keybind_resource.move_up_key
			keybind_resource.MOVE_DOWN:
				return keybind_resource.move_down_key
			keybind_resource.INTERACT:
				return keybind_resource.interact_key
			keybind_resource.DASH:
				return keybind_resource.dash_key
			keybind_resource.SLOT_1:
				return keybind_resource.slot_1_key
			keybind_resource.SLOT_2:
				return keybind_resource.slot_2_key
			keybind_resource.SLOT_3:
				return keybind_resource.slot_3_key
			keybind_resource.SLOT_4:
				return keybind_resource.slot_4_key
			keybind_resource.SLOT_5:
				return keybind_resource.slot_5_key

## connect all signals from SettingManager (will refactor to lambda)
func handle_signals() -> void:
	SettingManager.load_settings_data.connect(on_load_settings_data)
	SettingManager.on_tooltip_enabled.connect(on_tooltip_enabled)
	SettingManager.on_window_selected.connect(on_window_selected)
	SettingManager.on_resolution_selected.connect(on_resolution_selected)
	SettingManager.on_master_vol_set.connect(on_master_vol_set)
	SettingManager.on_music_vol_set.connect(on_music_vol_set)
	SettingManager.on_sfx_vol_set.connect(on_sfx_vol_set)

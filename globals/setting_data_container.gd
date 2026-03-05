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

# Map action -> resource property name
@onready var ACTION_TO_BIND_PROP: Dictionary = {
	keybind_resource.MOVE_LEFT: "move_left_key",
	keybind_resource.MOVE_RIGHT: "move_right_key",
	keybind_resource.MOVE_UP: "move_up_key",
	keybind_resource.MOVE_DOWN: "move_down_key",
	keybind_resource.INTERACT: "interact_key",
	keybind_resource.DASH: "dash_key",
	keybind_resource.SLOT_1: "slot_1_key",
	keybind_resource.SLOT_2: "slot_2_key",
	keybind_resource.SLOT_3: "slot_3_key",
	keybind_resource.SLOT_4: "slot_4_key",
	keybind_resource.SLOT_5: "slot_5_key"
}

# Map action -> default property name
@onready var ACTION_TO_DEFAULT_PROP: Dictionary = {
	keybind_resource.MOVE_LEFT: "DEFAULT_MOVE_LEFT_KEY",
	keybind_resource.MOVE_RIGHT: "DEFAULT_MOVE_RIGHT_KEY",
	keybind_resource.MOVE_UP: "DEFAULT_MOVE_UP_KEY",
	keybind_resource.MOVE_DOWN: "DEFAULT_MOVE_DOWN_KEY",
	keybind_resource.INTERACT: "DEFAULT_INTERACT_KEY",
	keybind_resource.DASH: "DEFAULT_DASH_KEY",
	keybind_resource.SLOT_1: "DEFAULT_SLOT_1_KEY",
	keybind_resource.SLOT_2: "DEFAULT_SLOT_2_KEY",
	keybind_resource.SLOT_3: "DEFAULT_SLOT_3_KEY",
	keybind_resource.SLOT_4: "DEFAULT_SLOT_4_KEY",
	keybind_resource.SLOT_5: "DEFAULT_SLOT_5_KEY",
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
		"keybinds": create_keybind_dict()
	}
	return setting_dict

## Will be created within the settings storage dictionary (nested dict)
# Created on save, used for loading
func create_keybind_dict() -> Dictionary:
	# Map from keybind container resource (custom keys, defaults already set)
	var keybind_dict: Dictionary = {}
	for action: String in ACTION_TO_BIND_PROP.keys():
		var key_name: String = ACTION_TO_BIND_PROP[action]
		var event: InputEvent = keybind_resource.get(key_name)
		keybind_dict[action] = event.physical_keycode
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
	var action_name: String = ACTION_TO_BIND_PROP.get(action)
	if action_name:
		keybind_resource.set(action_name,event)

# I DO NOT LIKE THIS AT ALL (Works but ugly), fuck ass tutorial
# Once the loaded config is loaded (via signal) assign each loaded value to the actual keybind
func on_keybinds_loaded(data: Dictionary) -> void:
	# match loaded in dictionary to each action
	for action: String in ACTION_TO_BIND_PROP.keys():
		# physical keycode of action, needed for Godot to bind
		var keycode: int = int(data.get(action))
		# the input event (move_left, dash, etc.) to bind the keycode to 
		var loaded_action: InputEvent = InputEventKey.new()
		loaded_action.physical_keycode = keycode
		# the input event name to set the loaded keybind in the resource
		var prop: String = ACTION_TO_BIND_PROP.get(action)
		keybind_resource.set(prop, loaded_action)

## Getter functions
func get_keybind(action: String) -> InputEventKey:
	# if keybinds were loaded use current
	var prop: String = ACTION_TO_BIND_PROP.get(action, "")
	if loaded_data.has("keybinds") and loaded_data.get("keybinds").has(action):
		if prop:
			return keybind_resource.get(prop)

	# otherwise fall back to default
	var default_property: String = ACTION_TO_DEFAULT_PROP.get(action, "")
	if default_property == "":
		return null
	return keybind_resource.get(default_property)

## connect all signals from SettingManager (will refactor to lambda)
func handle_signals() -> void:
	SettingManager.load_settings_data.connect(on_load_settings_data)
	SettingManager.on_tooltip_enabled.connect(on_tooltip_enabled)
	SettingManager.on_window_selected.connect(on_window_selected)
	SettingManager.on_resolution_selected.connect(on_resolution_selected)
	SettingManager.on_master_vol_set.connect(on_master_vol_set)
	SettingManager.on_music_vol_set.connect(on_music_vol_set)
	SettingManager.on_sfx_vol_set.connect(on_sfx_vol_set)

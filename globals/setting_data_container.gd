extends Node

## Tracks all current settings state in one place in code
##
## Contains callback functions called from SettingManager
## Callbacks edit the current state of the settings
## When saving, the state of current settings gets written to file by SaveManager
## When loading, the state of settings gets overwritten by loaded file values, else default

# Keybind resource reference, contains Default keybind information and assigned keybinds
# Acts as state container for keybinds specifically
@onready var keybind_resource : KeybindContainer = preload("res://scenes/ui/default_keybinds.tres")

# Relevant setting values
var tooltip_enabled: bool = true
var window_mode_index: int = 0
var resolution_mode_index: int = 0
# Volumes stored are db values (converted to linear later)
var master_volume: float = 0.0
var music_volume: float = 0.0
var sfx_volume: float = 0.0

# Loaded data from file
var loaded_data: Dictionary = {}

# Maps action -> resource property name
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

# Maps action -> default property name
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

## Initializes the settings container and connects to SettingManager signals.[br][br]
##
## This function is called once on game startup. It ensures the container is
## listening for load signals, and can produce a settings dictionary for saving.
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

## Initializes the keybind container (within the storage dict)
func create_keybind_dict() -> Dictionary:
	# Map from keybind container resource (custom keys, else defaults already set)
	var keybind_dict: Dictionary = {}
	for action: String in ACTION_TO_BIND_PROP.keys():
		var key_name: String = ACTION_TO_BIND_PROP[action]
		var event: InputEvent = keybind_resource.get(key_name)
		keybind_dict[action] = event.physical_keycode
	return keybind_dict
#TODO From vid, extra getters to validate and return defaults for missing values (create resource file)

## Applies loaded settings data from file into this container.[br][br]
##
## Called when SaveManager emits a loaded settings dictionary through SettingManager.
## (ie once settings config file detected)
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

## Setter functions for updating setting state
## Signal related data to set
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

# I DO NOT LIKE THIS AT ALL (Works but ugly), fuck ass tutorial
## Loads keybind overrides from a saved dictionary.[br][br]
##
## For each supported action, reads the saved physical_keycode integer and
## constructs an InputEventKey to store into the keybind resource.
func on_keybinds_loaded(keybind_data: Dictionary) -> void:
	if keybind_data == null or keybind_data.is_empty():
		return
	for action: String in ACTION_TO_BIND_PROP.keys():
		if not keybind_data.has(action):
			continue
		var keycode: int = int(keybind_data.get(action))
		if keycode <= 0:
			continue
		var event: InputEvent = InputEventKey.new()
		event.physical_keycode = keycode
		# Assign new InputEventKey to keyboard resource
		var prop: String = ACTION_TO_BIND_PROP.get(action, "")
		if prop != "":
			keybind_resource.set(prop, event)

## Setter functions for rebinding keys
func set_keybind(action: String, event: InputEventKey) -> void:
	var action_name: String = ACTION_TO_BIND_PROP.get(action)
	if action_name:
		keybind_resource.set(action_name,event)

## Getter functions
## Returns current keybind state of the given action [br][br]
##
## Takes in parameters:[param p3] action: InputMap action name.[br][br]
func get_keybind(action: String) -> InputEventKey:
	# if keybinds were loaded use current
	if loaded_data.has("keybinds") and loaded_data["keybinds"].has(action):
		var prop: String = ACTION_TO_BIND_PROP.get(action, "")
		if prop == "":
			return null
		return keybind_resource.get(prop)

	# otherwise fall back to default
	var default_prop: String = ACTION_TO_DEFAULT_PROP.get(action, "")
	if default_prop == "":
		return null
	return keybind_resource.get(default_prop)

## connect all signals from SettingManager (maybe refactor to a lambda)
func handle_signals() -> void:
	SettingManager.load_settings_data.connect(on_load_settings_data)
	SettingManager.on_tooltip_enabled.connect(on_tooltip_enabled)
	SettingManager.on_window_selected.connect(on_window_selected)
	SettingManager.on_resolution_selected.connect(on_resolution_selected)
	SettingManager.on_master_vol_set.connect(on_master_vol_set)
	SettingManager.on_music_vol_set.connect(on_music_vol_set)
	SettingManager.on_sfx_vol_set.connect(on_sfx_vol_set)

extends Node

## Default Setting values
var tooltip_enabled: bool = true
var window_mode_index: int = 0
var resolution_mode_index: int = 0
# Volumes stored are db values
var master_volume: float = 0.0
var music_volume: float = 0.0
var sfx_volume: float = 0.0

## Save loaded data
var loaded_data: Dictionary = {}

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
		"move_right": InputMap.action_get_events("move_right")
	}
	return setting_dict

#TODO From vid, extra getters to validate and return defaults for missing values (create resource file)

# Signal related data to load (parameter of settings data loaded in)
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

## connect all signals from SettingManager (will refactor to lambda)
func handle_signals() -> void:
	SettingManager.load_settings_data.connect(on_load_settings_data)
	SettingManager.on_tooltip_enabled.connect(on_tooltip_enabled)
	SettingManager.on_window_selected.connect(on_window_selected)
	SettingManager.on_resolution_selected.connect(on_resolution_selected)
	SettingManager.on_master_vol_set.connect(on_master_vol_set)
	SettingManager.on_music_vol_set.connect(on_music_vol_set)
	SettingManager.on_sfx_vol_set.connect(on_sfx_vol_set)

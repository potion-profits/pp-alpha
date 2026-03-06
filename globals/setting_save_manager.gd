extends Node

## Responsible for the settings.config file (loading and saving/creating)
##
## Fetches current settings state and saves/creates a file
## Also calls load setting function when loading from file 

const CONFIG_PATH: String = "user://settings.cfg"
# Dictionary used when saving
var setting_data_dict: Dictionary = {}
# Dictionary used when loading
var loaded_settings_dict: Dictionary = {}

func _ready() -> void:
	# connect signal
	SettingManager.set_settings_dict.connect(on_settings_save)
	# load data from file
	load_settings_data()

## Saves to config file [br][br]
##
## If config file does not exist, automatically create one
## else overwrite existing config
func on_settings_save(data: Dictionary) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	# ConfigFile class auto serializes dict entries
	cfg.set_value("settings","data", data)
	cfg.save(CONFIG_PATH)

## Loads setting from config file [br][br]
##
## Loads in config file and updates current setting state
## on_settings_save ensures a config file exists
func load_settings_data() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: Error = cfg.load(CONFIG_PATH)
	if err != OK:
		return
	
	loaded_settings_dict.clear()
	# Grab keys to write into dictionary
	var keys: Array = cfg.get_section_keys("settings")
	if keys == null: 
		return
	
	for key: String in keys:
		loaded_settings_dict[key] = cfg.get_value("settings", key)
	# Emit loaded data signal, listened by setting data container
	SettingManager.emit_load_settings_data(loaded_settings_dict)

extends Node

const CONFIG_PATH: String = "user://settings.cfg"
var setting_data_dict: Dictionary = {}
var loaded_settings_dict: Dictionary = {}

func _ready() -> void:
	# connect signal
	SettingManager.set_settings_dict.connect(on_settings_save)
	# load data
	load_settings_data()

# Saves to config file
func on_settings_save(data: Dictionary) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	# ConfigFile class auto serializes dict entries
	cfg.set_value("settings","data", data)
	cfg.save(CONFIG_PATH)

func load_settings_data() -> void:
	var cfg:ConfigFile = ConfigFile.new()
	var err:Error = cfg.load(CONFIG_PATH)
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

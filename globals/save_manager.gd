extends Node

const CONFIG_PATH: String = "user://settings.cfg"
var setting_data_dict: Dictionary = {}

func _ready() -> void:
	SettingManager.set_settings_dict.connect(on_settings_save)

# Saves to encrypted file
func on_settings_save(data: Dictionary) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	# Godot auto serializes dict entries
	cfg.set_value("settings","data", data)
	cfg.save(CONFIG_PATH)

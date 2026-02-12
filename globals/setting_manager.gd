extends Node

# On index from dropdown menu
# Signals emitted from each respective option scene
signal on_tooltip_enabled(enabled: bool)
signal on_window_selected(index: int)
signal on_resolution_selected(index: int)
signal on_master_vol_set(value: float)
signal on_music_vol_set(value: float)
signal on_sfx_vol_set(value: float)

# Save/Loading settings data related signals
signal set_settings_dict(seting_dict: Dictionary)
signal load_settings_data(setting_dict: Dictionary)

func emit_set_settings_dict(setting_dict: Dictionary) -> void:
	set_settings_dict.emit(setting_dict)

func emit_load_settings_data(setting_dict: Dictionary) -> void:
	load_settings_data.emit(setting_dict)

func emit_on_tooltip_enabled(enabled: bool) -> void:
	on_tooltip_enabled.emit(enabled)

func emit_on_window_selected(index: int) -> void:
	on_window_selected.emit(index)

func emit_on_resultion_selected(index: int) -> void:
	on_resolution_selected.emit(index)

func emit_on_master_vol_set(value: float) -> void:
	on_master_vol_set.emit(value)

func emit_on_music_vol_set(value: float) -> void:
	on_music_vol_set.emit(value)

func emit_on_sfx_vol_set(value: float) -> void:
	on_sfx_vol_set.emit(value)

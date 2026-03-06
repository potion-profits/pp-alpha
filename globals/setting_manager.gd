extends Node

# Acts as a signal bus from the option tab scenes to the settings data container
#
# SettingsDataContainer + SavingManager connects these signals to saving/loading callbacks
# Designed to decouple each option scenes signals and signals to save settings

# Indexes based from dropdown menu
# Signals emitted from each respective option scene
signal on_tooltip_enabled(enabled: bool)
signal on_window_selected(index: int)
signal on_resolution_selected(index: int)
signal on_master_vol_set(value: float)
signal on_music_vol_set(value: float)
signal on_sfx_vol_set(value: float)

# Save/Loading data settings related signals
signal set_settings_dict(seting_dict: Dictionary)
signal load_settings_data(setting_dict: Dictionary)

## Emits a request to save the current settings dictionary.[br][br]
##
## This does not write to disk by itself. Instead, it broadcasts a signal that
## SettingSaveManager listens to in order to serialize and save settings.
func emit_set_settings_dict(setting_dict: Dictionary) -> void:
	set_settings_dict.emit(setting_dict)

## Emits a request to load the settings dictionary from file.[br][br]
##
## This does not read from disk by itself. Instead, it broadcasts a signal that
## SettingSaveManager listens to in order to fetch file data to a dictionary.
func emit_load_settings_data(setting_dict: Dictionary) -> void:
	load_settings_data.emit(setting_dict)

## Below emits all relevant setting information for the SettingsDataContainer
func emit_on_tooltip_enabled(enabled: bool) -> void:
	on_tooltip_enabled.emit(enabled)

func emit_on_window_selected(index: int) -> void:
	on_window_selected.emit(index)

func emit_on_resolution_selected(index: int) -> void:
	on_resolution_selected.emit(index)

func emit_on_master_vol_set(value: float) -> void:
	on_master_vol_set.emit(value)

func emit_on_music_vol_set(value: float) -> void:
	on_music_vol_set.emit(value)

func emit_on_sfx_vol_set(value: float) -> void:
	on_sfx_vol_set.emit(value)

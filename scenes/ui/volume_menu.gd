extends Control

## Handles volume control over busses (Music, SFX, and Main)

@onready var MASTER_BUS_IDX: int = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_IDX: int = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_IDX: int = AudioServer.get_bus_index("SFX")
@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/Master
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/Music
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/SFX

func _ready()->void:
	init_sliders()

## Initializes slider values to represent current bus layout[br][br]
##
## Must be called within _ready()
## First loads all saved settings data from settings data container (reads from config file)
func init_sliders() -> void:
	# load slider visuals
	master_slider.value = db_to_linear(SettingDataContainer.master_volume)
	music_slider.value = db_to_linear(SettingDataContainer.music_volume)
	sfx_slider.value = db_to_linear(SettingDataContainer.sfx_volume)
	# load actual volume values
	AudioServer.set_bus_volume_db(MASTER_BUS_IDX, SettingDataContainer.master_volume)
	AudioServer.set_bus_volume_db(MUSIC_BUS_IDX, SettingDataContainer.music_volume)
	AudioServer.set_bus_volume_db(SFX_BUS_IDX, SettingDataContainer.sfx_volume)

# Slider value changed signals for each respective slider
# Sliders provide linear values (0 - 1) 
# The values to set volume bus 
func _on_master_value_changed(value: float) -> void:
	SettingManager.emit_on_master_vol_set(linear_to_db(value))
	AudioServer.set_bus_volume_db(MASTER_BUS_IDX, linear_to_db(value))

func _on_music_value_changed(value: float) -> void:
	SettingManager.emit_on_music_vol_set(linear_to_db(value))
	AudioServer.set_bus_volume_db(MUSIC_BUS_IDX, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	SettingManager.emit_on_sfx_vol_set(linear_to_db(value))
	AudioServer.set_bus_volume_db(SFX_BUS_IDX, linear_to_db(value))

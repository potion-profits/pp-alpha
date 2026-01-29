extends "res://scenes/ui/base_menu.gd"

## Handles volume control over busses (Music, SFX, and Main)

@onready var MASTER_BUS_IDX: int = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_IDX: int = AudioServer.get_bus_index("Music")
@onready var SFX_BUS_IDX: int = AudioServer.get_bus_index("SFX")
@onready var master_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/Master
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/Music
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/VolumeBG/VolumeContainer/SFX

func _ready()->void:
	init_sliders()
	button_map = {
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres"
	}
	super._ready()

func init_sliders() -> void:
	# Set default slider values to represent current bus layout
	# Syncs current volume to slider value
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(MASTER_BUS_IDX))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(MUSIC_BUS_IDX))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(SFX_BUS_IDX))

func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MASTER_BUS_IDX, linear_to_db(value))

func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(MUSIC_BUS_IDX, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SFX_BUS_IDX, linear_to_db(value))

func _on_options_pressed() -> void:
	SceneManager.change_to("res://scenes/ui/options_menu.tscn")

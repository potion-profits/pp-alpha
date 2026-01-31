extends "res://scenes/ui/base_menu.gd"

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres"
	}
	super._ready()

func _on_options_pressed() -> void:
	SceneManager.change_to("res://scenes/ui/options_menu.tscn")

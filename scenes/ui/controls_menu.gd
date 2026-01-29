extends "res://scenes/ui/base_menu.gd"

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres"
	}
	super._ready()

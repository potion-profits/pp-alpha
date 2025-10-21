extends "res://scripts/ui/base_menu.gd"

func _ready():
	button_map = {
		"MarginContainer/VBoxContainer/Play": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres",
		"MarginContainer/VBoxContainer/Quit": "res://assets/ui/quit_button.tres"
	}
	super._ready()


func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/playground.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

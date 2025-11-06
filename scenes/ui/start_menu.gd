extends "res://scenes/ui/base_menu.gd"

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Play": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres",
		"MarginContainer/VBoxContainer/Quit": "res://assets/ui/quit_button.tres"
	}
	super._ready()


func _on_play_pressed()->void:
	get_tree().change_scene_to_file("res://scenes/pookie_wookie_ozzie/pickup_play.tscn")

func _on_options_pressed()->void:
	get_tree().change_scene_to_file("res://scenes/ui/options_menu.tscn")

func _on_quit_pressed()->void:
	Database.close()
	await get_tree().process_frame
	get_tree().quit()

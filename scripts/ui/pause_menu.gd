extends "res://scripts/ui/base_menu.gd"


func _ready():
	button_map = {
		"MarginContainer/VBoxContainer/Resume": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()


func _on_menu_pressed():
	#save and return to menu!! for now just menu
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")


func _on_resume_pressed():
	GameManager.unpause()

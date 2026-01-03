extends "res://scenes/ui/base_menu.gd"


func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Resume": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()


func _on_menu_pressed()->void:
	#save and return to menu!! for now just menu
	SceneManager.change_to("res://scenes/ui/start_menu.tscn")


func _on_resume_pressed()->void:
	GameManager.unpause()

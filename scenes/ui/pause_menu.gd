extends "res://scenes/ui/base_menu.gd"

## Handles the pause menu options.
##
## Has the option to unpause the game and to return to the main menu.

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Resume": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()


func _on_menu_pressed()->void:
	#save and return to menu!! for now just menu
	#unpause tree when returning to menu (so menu processes are not paused)
	get_tree().paused = false
	SceneManager.change_to("res://scenes/ui/start_menu.tscn")


func _on_resume_pressed()->void:
	GameManager.unpause()

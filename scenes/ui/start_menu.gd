extends "res://scenes/ui/base_menu.gd"

## Handles the initial menu that is shown to the user.
##
## Has the ability to play the game, open the options, and quit/close the game.

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Play": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres",
		"MarginContainer/VBoxContainer/Quit": "res://assets/ui/quit_button.tres"
	}
	super._ready()


func _on_play_pressed()->void:
	SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")
	TimeManager.set_process(true)

func _on_options_pressed()->void:
	SceneManager.change_to("res://scenes/ui/options_menu.tscn")

func _on_quit_pressed()->void:
	#we will hard save here for now
	#GameManager.commit_to_storage()
	get_tree().quit()

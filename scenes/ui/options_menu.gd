extends "res://scenes/ui/base_menu.gd"

## Handles all the buttons in the options menu
##
## @experimental: Currently, the buttons kind of do nothing important

func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Music": "res://assets/ui/music_button.tres",
		"MarginContainer/VBoxContainer/Volume": "res://assets/ui/volume_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()

func _on_menu_pressed()->void:
	go_to_start()
	
func _on_lang_pressed()->void:
	LanguageManager.next_language()

func _on_music_pressed() -> void:
	pass # Replace with function body.

func _on_volume_pressed() -> void:
	SceneManager.change_to("res://scenes/ui/volume_menu.tscn")

func _input(event: InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
		go_to_start()

func go_to_start()->void:
	SceneManager.change_to("res://scenes/ui/start_menu.tscn")

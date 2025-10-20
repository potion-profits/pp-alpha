extends "res://scripts/ui/base_menu.gd"

func _ready():
	button_map = {
		"MarginContainer/VBoxContainer/Music": "res://assets/ui/music_button.tres",
		"MarginContainer/VBoxContainer/Volume": "res://assets/ui/volume_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
	
	
func _on_lang_pressed():
	LanguageManager.next_language()

func _on_music_pressed() -> void:
	pass # Replace with function body.


func _on_volume_pressed() -> void:
	pass # Replace with function body.

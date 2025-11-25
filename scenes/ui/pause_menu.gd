extends "res://scenes/ui/base_menu.gd"


func _ready()->void:
	button_map = {
		"MarginContainer/VBoxContainer/Resume": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Menu": "res://assets/ui/menu_button.tres"
	}
	super._ready()


func _on_menu_pressed()->void:
	#save and return to menu!! for now just menu
	var cs:String = get_tree().current_scene.name
	GameManager.save_scene_runtime_state(cs)
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")


func _on_resume_pressed()->void:
	GameManager.unpause()

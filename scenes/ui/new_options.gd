extends "res://scenes/ui/base_menu.gd"

func _ready() -> void:
	super._ready()


func _on_exit_pressed() -> void:
	print("PRESSED")
	SceneManager.change_to("res://scenes/ui/start_menu.tscn")

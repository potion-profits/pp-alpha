extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var pause_scene = preload("res://scenes/pause_menu.tscn")
	var menu_instance = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))

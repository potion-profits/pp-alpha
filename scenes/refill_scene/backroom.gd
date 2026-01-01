extends Node2D

@onready var player: Player = $EntityManager/Player
@onready var static_ui: CanvasLayer = $Static_UI

var orig_inv_ui_pos: Vector2
var ui_tween: Tween

func _ready()->void:
	player.set_physics_process(false)
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	await get_tree().process_frame
	

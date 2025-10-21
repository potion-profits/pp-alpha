extends Node2D

@onready var player : = $Player
@onready var texture_progress_bar : = $Player/TextureProgressBar

func _on_player_stamina_change(stamina : float) -> void:
	var percent : float = stamina / float(player.STAMINA)
	#print("Stamina: ", stamina, "\tPercent: ", percent)
	texture_progress_bar.value = percent * 100

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))

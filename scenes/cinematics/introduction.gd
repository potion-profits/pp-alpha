extends Node2D

@onready var timer: Timer = $Timer


func _ready() -> void:
	play_intro()
	
func play_intro()->void:
	if OS.is_debug_build():
		timer.start(2)
	else:
		timer.start(10)

func _on_timer_timeout() -> void:
	GameManager.initial_play = false
	SceneManager.change_to("res://scenes/penthouse/penthouse.tscn")

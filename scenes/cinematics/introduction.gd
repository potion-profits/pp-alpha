extends Node2D

@onready var timer: Timer = $Timer


func _ready() -> void:
	play_intro()
	
func play_intro()->void:
	timer.start(10)

func _on_timer_timeout() -> void:
	SceneManager.change_to("res://scenes/casino_floor/penthouse.tscn")

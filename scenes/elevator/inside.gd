extends Node2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.start(2)
	#start buzzing and such

func _on_timer_timeout() -> void:
	#ding
	SceneManager.change_to("res://scenes/penthouse/penthouse.tscn")

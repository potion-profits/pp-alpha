extends Node2D
@onready var timer: Timer = $Timer

var pload : Dictionary

func _ready() -> void:
	timer.start(7)
	#start buzzing and such
	pload = SceneManager.get_payload()

func _on_timer_timeout() -> void:
	#ding
	SceneManager.change_to(pload.get("destination", "res://scenes/casino/casino_floor.tscn"))

extends Node2D

@onready var timer : Timer = $Timer
@onready var dialogue_ui : CanvasLayer = $DialogueUI
@onready var credits : CanvasLayer = $CanvasLayer
var credits_roll : bool = false

func _ready() -> void:
	credits.set_process(false)
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	timer.start(5.0)
	credits.credit_ended.connect(_on_credits_ended)

func _on_timer_timeout() -> void:
	if not credits_roll:
		dialogue_ui.open("game_over", "game_over")
	
func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	if action == "roll_credits":
		credits_roll = true
		dialogue_ui.close()
		credits.set_process(true)
		

func _on_credits_ended() -> void:
	GameManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")

extends Node2D

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var canvas_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	canvas_layer.credit_ended.connect(_on_credit_ended)
	dialogue_ui.action_triggered.connect(_on_action)
	
func _on_credit_ended()->void:
	dialogue_ui.open("credits", "prompt")

func _on_action(action: String, _data: Dictionary) ->void:
	if action == "Restart":
		dialogue_ui.close()
		GameManager.delete_save()
		#get_tree().change_scene_to_file("res://scenes/ui/start_menu.tscn")
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

	if action == "Continue":
		dialogue_ui.close()
		GameManager.player_passed_out = true
		TimeManager.day_end.emit()

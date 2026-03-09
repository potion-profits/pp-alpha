extends Node2D

@onready var player: Player = $"y-sort/Player"
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var camera: Camera2D = $"y-sort/Player/Camera2D"
@onready var elevator: Elevator = $Elevator

func _ready() -> void:
	camera.reset_smoothing()
	elevator.set_floor(1)
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	elevator.interactable.interact = open_elevator_dialogue


func prep_dialogue_open() ->void:
	var last_dir: String = player.last_dir
	var player_idle_dir: String = "idle_" + last_dir
	player.animated_sprite.play(player_idle_dir)
	player.set_physics_process(false)

func open_elevator_dialogue() -> void:
	prep_dialogue_open()
	dialogue_ui.open("elevator","penthouse_prompt")
	
func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	if action == "elevator_enter":
		dialogue_ui.close()
		play_elevator_down()


func play_elevator_down()->void:
	player.set_physics_process(false)
	elevator.start_anim()

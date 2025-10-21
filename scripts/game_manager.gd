extends Node

var pause_menu: Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called when the node enters the scene tree for the first time.
func set_pause_menu(menu: Control):
	pause_menu = menu
	unpause()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
#		Case where pausing is allowed
		if(pause_menu):
			get_tree().paused = !get_tree().paused
			pause_menu.visible = get_tree().paused

func unpause():
	if (pause_menu):
		get_tree().paused = false
		pause_menu.hide()
		pause_menu.visible = false

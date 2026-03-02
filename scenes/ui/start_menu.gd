extends "res://scenes/ui/base_menu.gd"

## Handles the initial menu that is shown to the user.
##
## Has the ability to play the game, open the options, and quit/close the game.

# Reference to animation player that contains the fade in transition
@onready var animation: AnimationPlayer = $FadeIn
# Reference to rectangle to fade into for animations
@onready var fade_color: ColorRect = $FadeColor

func _ready()->void:
	# fade in the start menu
	if !OS.is_debug_build():
		play_fade_in()
	# debug mode defaults the buttons to original position
	else:
		animation.play("RESET")
	button_map = {
		"MarginContainer/VBoxContainer/Play": "res://assets/ui/play_button.tres",
		"MarginContainer/VBoxContainer/Options": "res://assets/ui/options_button.tres",
		"MarginContainer/VBoxContainer/Quit": "res://assets/ui/quit_button.tres"
	}
	super._ready()

func _on_play_pressed()->void:
	SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")

func _on_options_pressed()->void:
	SceneManager.change_to("res://scenes/ui/options_menu.tscn")

func _on_quit_pressed()->void:
	#we will hard save here for now
	#GameManager.commit_to_storage()
	get_tree().quit()

func play_fade_in() -> void:
	fade_color.visible = true
	animation.play("fade_in")
	# this timer must match fade in time to ensure ColorRect not removed early
	await get_tree().create_timer(4.0).timeout
	# remove ColorRect node to not block inputs
	fade_color.queue_free()

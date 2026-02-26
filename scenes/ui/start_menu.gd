extends "res://scenes/ui/base_menu.gd"

## Handles the initial menu that is shown to the user.
##
## Has the ability to play the game, open the options, and quit/close the game.

# Reference to animation player that contains the fade in transition
@onready var animation: AnimationPlayer = $FadeIn
# Reference to rectangle used for animations
@onready var fade_color: ColorRect = $ColorRect

func _ready()->void:
	# fade in the start menu (Need to discuss: fade on all switches to start menu?)
	if !OS.is_debug_build():
		play_fade_in()
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
	animation.play("fade_in")
	# remove color rect node to not block inputs once fade is finished
	await get_tree().create_timer(4.0).timeout
	fade_color.queue_free()

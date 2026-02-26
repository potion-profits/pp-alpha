extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if OS.is_debug_build():
		play_logos()
	

# Plays logos (Godot Engine, Studio Logo)
func play_logos() -> void:
	if animation:
		animation.play("fade_in")
		# time for logo to appear
		await get_tree().create_timer(6.0).timeout
		animation.play("fade_out")
		# this timer must match fade out time to ensure scene switch after fade is finished
		await get_tree().create_timer(3.0).timeout
		# Switch to main menu 
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

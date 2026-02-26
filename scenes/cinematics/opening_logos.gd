extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var shay : AnimatedSprite2D = $Shay
@onready var godot_logo: Sprite2D = $GodotLogo
@onready var studio_logo: Sprite2D = $StudioLogo

func _ready() -> void:
	if !OS.is_debug_build():
		play_logos()

# Plays logos (Godot Engine, Studio Logo)
func play_logos() -> void:
	if animation:
		# Play Godot Logo
		animation.play("fade_in")
		# time for logo to appear
		await get_tree().create_timer(4.5).timeout
		animation.play("fade_out")
		# this timer must match fade out time to ensure scene switch after fade is finished
		await get_tree().create_timer(3.0).timeout
		
		# switch logo states
		godot_logo.visible = false
		studio_logo.visible = true
		shay.visible = true
		
		# Play studio logo
		shay.play("walk_left")
		animation.play("fade_in")
		await get_tree().create_timer(4.5).timeout
		animation.play("fade_out")
		await get_tree().create_timer(3.0).timeout
		
		# Switch to main menu 
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

extends Control

@onready var animation: AnimationPlayer = $AnimationPlayer
# Reference to the animated Shay sprite playing for the studio logo
@onready var shay : AnimatedSprite2D = $Shay
@onready var godot_logo: Sprite2D = $GodotLogo
@onready var studio_logo: Sprite2D = $StudioLogo

# time for logo to appear
const logo_time: float = 3.5
# timer must match fade out time to ensure logo switch after fade is finished
const fade_out_time: float = 1.5

func _ready() -> void:
	if !OS.is_debug_build():
		play_logos()
	# Debug mode skips logos
	else:
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

## Plays logos when called (Currently: Godot Engine, Studio Logo)
func play_logos() -> void:
	if animation:
		# Play Godot Logo
		animation.play("fade_in")
		await get_tree().create_timer(logo_time).timeout
		animation.play("fade_out")
		await get_tree().create_timer(fade_out_time).timeout
		
		# switch logo states
		godot_logo.visible = false
		studio_logo.visible = true
		shay.visible = true
		
		# Play Studio Cejjo logo
		shay.play("walk_left")
		animation.play("fade_in")
		await get_tree().create_timer(logo_time).timeout
		animation.play("fade_out")
		await get_tree().create_timer(fade_out_time).timeout
		
		# Switch to main menu 
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

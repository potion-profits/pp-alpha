extends Area2D

@export var animation_name: String = "default"  # Name of animation to play
@onready var mix_timer: Timer = get_parent().get_node("Timer")
@onready var progress_bar: TextureProgressBar = get_parent().get_node("ProgressBar")

#used to check the player that can interact
var player: PhysicsBody2D = null
#tracks if player can interact
var player_in_area:bool = false

const MIX_DURATION := 3.0

var count:int = 0
var is_mixing: bool = false

@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("CauldronAnim")

#lets player interact if in the area
func _input(event: InputEvent) -> void:
	if player_in_area == true:	
		if event.is_action_pressed("interact"):
			start_mixing()

#tracks when player is in area and sets the player
func _on_interactable_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		player_in_area = true

#tracks when player leaves area
func _on_interactable_area_body_exited(body : Node) -> void:
	if body.name == "Player":
		player_in_area = false
		
#on interact, animation plays on sprite
func animation_play() -> void:
	if animated_sprite and animated_sprite.sprite_frames.has_animation(animation_name):
		animated_sprite.play(animation_name)
	else:
		push_error("AnimatedSprite2D or animation '" + animation_name + "' not found!")
		
func start_mixing()->void:
	if mix_timer:
		mix_timer.wait_time = MIX_DURATION
		mix_timer.start() 
		is_mixing = true
		progress_bar.visible = true
	animation_play()
	
# progress per frame
func _process(_delta: float) -> void:
	if is_mixing:
		var progress_fill: float = (mix_timer.time_left / MIX_DURATION) * 100
		progress_bar.value = progress_fill

# reset progress when time ends
func _on_timer_timeout() -> void:
	progress_bar.visible = false
	progress_bar.value = 100
	is_mixing = false

extends PhysicsBody2D

const SPEED = 300
const STAMINA = 50
const STAMINA_RECHARGE_RATE = 10

var velocity : Vector2
var stamina : float = STAMINA
var last_direction : Vector2 = Vector2(0, 1) # ADDED: default facing down

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var sprint_timer : Timer = $SprintTimer

signal stamina_change

enum movement_state {
	IDLE,
	WALK,
	SPRINT
}

var current_state : movement_state = movement_state.IDLE

func _physics_process(delta : float)->void:
	# allow variable screen sizes
	var screen_size : Vector2 = get_viewport_rect().size
	# reset speed and sprint flag each tick
	velocity = Vector2(0,0)
	
	var stamina_delta : float = STAMINA_RECHARGE_RATE * delta
	
	# Get input direction
	var y_dir : float = Input.get_axis("move_up", "move_down")
	var x_dir : float = Input.get_axis("move_left", "move_right")
	
	# CHANGED: Store direction for animation
	if x_dir or y_dir:
		velocity = Vector2(x_dir, y_dir)
		last_direction = velocity.normalized()
	
	velocity = velocity.normalized() * SPEED * delta
	
	var sprint : bool = Input.is_action_pressed("sprint")
	
	if x_dir or y_dir:
		if sprint and stamina > 0:
			current_state = movement_state.SPRINT
		else:
			current_state = movement_state.WALK
	else:
		current_state = movement_state.IDLE
	
	# Get animation based on direction
	# Uses function get_animation_name
	var anim_name : String = get_animation_name(last_direction, current_state)
	
	match current_state:
		movement_state.IDLE:
			animated_sprite.play(anim_name) 
			animated_sprite.speed_scale = 1.0
			if sprint_timer.is_stopped():
				stamina += stamina_delta
		movement_state.WALK:
			animated_sprite.play(anim_name) 
			animated_sprite.speed_scale = 1.0
			if sprint_timer.is_stopped():
				stamina += stamina_delta
		movement_state.SPRINT:
			animated_sprite.play(anim_name) 
			animated_sprite.speed_scale = 2.0
			velocity *= 2
			stamina -= 2 * stamina_delta
			if stamina < STAMINA and sprint_timer.is_stopped():
				sprint_timer.start(2.0)
	stamina = min(stamina, STAMINA)
	
	move_and_collide(velocity)
	
	stamina_change.emit(stamina)
	
	print(sprint_timer.time_left) 
	
	# locks character to rectangle from (0,0) to (sreen_size.x, screen_size.y)
	global_position = global_position.clamp(Vector2(0,0), screen_size)

# ADDED: New function to determine animation based on direction 
# uses angles 
func get_animation_name(direction : Vector2, state : movement_state) -> String:
	var prefix : String = "idle_" if state == movement_state.IDLE else "walk_"
	
	# Determine primary direction
	var angle : float = direction.angle()
	var degrees : float = rad_to_deg(angle)
	
	# Normalize to 0-360
	if degrees < 0:
		degrees += 360
	
	# Handle horizontal flipping (sprites default to left, flip for right)
	if degrees < 90 or degrees > 270:  # Right side
		animated_sprite.flip_h = true
	else:  # Left side
		animated_sprite.flip_h = false
	
	# Determine animation 
	if (degrees >= 157.5 and degrees < 202.5) or (degrees >= 337.5 or degrees < 22.5):
		return prefix + "left"
	elif (degrees >= 112.5 and degrees < 157.5) or (degrees >= 22.5 and degrees < 67.5):
		return prefix + "down_left"
	elif degrees >= 67.5 and degrees < 112.5:
		return prefix + "down"
	elif (degrees >= 202.5 and degrees < 247.5) or (degrees >= 292.5 and degrees < 337.5):
		return prefix + "up_left"
	else: # 247.5 to 292.5
		return prefix + "up"

func _on_sprint_timer_timeout() -> void:
	sprint_timer.stop()

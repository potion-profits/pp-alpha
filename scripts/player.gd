extends PhysicsBody2D

const SPEED = 150
const DASH_MULT = 2.2
const DASH_DURATION = 0.17
const DASH_COOLDOWN = 0.5
const MAX_COINS = pow(2, 62)

var coins : int = 500 # replace value with db call once implemented
var chips : int = 10 # replace value with db call once implemented
var velocity : Vector2
var is_dashing : bool = false
@onready var animated_sprite :  = $AnimatedSprite2D
@onready var dash_cooldown: Timer = $DashCooldown
@onready var dash_duration: Timer = $DashDuration

enum movement_state {
	IDLE,
	WALK,
	DASH
}

var current_state : movement_state = movement_state.IDLE

func _physics_process(delta : float)->void:
	move(current_state, delta)
	move_and_collide(velocity)
	
func move(curr_state : movement_state, delta : float) -> void:
	match curr_state:
		movement_state.IDLE:
			get_movement_input(delta)
			animated_sprite.play("default")
			animated_sprite.speed_scale = 1.0
		movement_state.WALK:
			get_movement_input(delta)
			animated_sprite.play("walk")
			animated_sprite.speed_scale = 1.0
		movement_state.DASH:
			animated_sprite.play("walk")
			animated_sprite.speed_scale = DASH_MULT
			

func get_movement_input(delta : float) -> void:
	# reset speed and each tick
	velocity = Vector2(0,0)
	
	# flips y direction to neg or positive based on keypress input
	var y_dir : float = Input.get_axis("move_up", "move_down")
	if y_dir:
		velocity.y = y_dir
	
	# flips x direction to neg or positive based on keypress input
	var x_dir : float = Input.get_axis("move_left", "move_right")
	if x_dir:
		velocity.x = x_dir
		if x_dir > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	
	velocity = velocity.normalized() * SPEED * delta
	
	var sprint : bool = Input.is_action_just_pressed("sprint")
	
	if x_dir or y_dir:
		if sprint and dash_cooldown.is_stopped():
			dash_duration.start(DASH_DURATION)
			velocity *= DASH_MULT
			current_state = movement_state.DASH
		else:
			current_state = movement_state.WALK
	else:
		current_state = movement_state.IDLE

func _on_dash_cooldown_timeout() -> void:
	dash_cooldown.stop()

func _on_dash_duration_timeout() -> void:
	dash_duration.stop()
	current_state = movement_state.IDLE
	dash_cooldown.start(DASH_COOLDOWN)

# update getters/setters for currency once db is implemented
func get_coins() -> int:
	return coins

func set_coins(coins_delta : int) -> int:
	var new_coins : int = coins + coins_delta
	if new_coins < 0 or new_coins > MAX_COINS:
		return coins
	coins = new_coins
	return new_coins

func get_chips() -> int:
	return chips

func set_chips(chips_delta : int) -> int:
	var new_chips : int = chips + chips_delta
	if new_chips < 0 or new_chips > MAX_COINS:
		return chips
	chips = new_chips
	return new_chips

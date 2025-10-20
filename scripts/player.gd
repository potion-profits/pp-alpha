extends PhysicsBody2D

const SPEED = 300
const STAMINA = 50

var velocity
var stamina = STAMINA
@onready var animated_sprite = $AnimatedSprite2D
@onready var sprint_timer = $SprintTimer
signal stamina_change

enum movement_state {
	idle,
	walk,
	sprint,
	exhausted
}

func _physics_process(delta):
	# allow variable screen sizes
	var screen_size = get_viewport_rect().size
	# reset speed each tick
	velocity = Vector2(0,0)
	
	# flips y direction to neg or positive based on keypress input
	var y_dir = Input.get_axis("move_up", "move_down")
	if y_dir:
		velocity.y = y_dir
	
	# flips x direction to neg or positive based on keypress input
	var x_dir = Input.get_axis("move_left", "move_right")
	if x_dir:
		velocity.x = x_dir
		if x_dir > 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	
	velocity = velocity.normalized() * SPEED * delta
	
	var sprint = Input.is_action_pressed("sprint")
	
	if x_dir or y_dir:
		if sprint and stamina > 0:
			change_state(movement_state.sprint)
		else:
			change_state(movement_state.walk)
	else:
		change_state(movement_state.idle)
	
	move_and_collide(velocity)
	if stamina < STAMINA and sprint_timer.is_stopped():
		sprint_timer.start(2.0)
	
	stamina_change.emit(stamina)
	
	# locks character to rectangle from (0,0) to (sreen_size.x, screen_size.y)
	global_position = global_position.clamp(Vector2(0,0), screen_size)

func change_state(state):
	match state:
		movement_state.idle:
			animated_sprite.play("default")
			animated_sprite.speed_scale = 1.0
		movement_state.walk:
			animated_sprite.play("walk")
			animated_sprite.speed_scale = 1.0
		movement_state.sprint:
			animated_sprite.play("walk")
			animated_sprite.speed_scale = 2.0
			velocity *= 2
			stamina -=1

func _on_sprint_timer_timeout():
	stamina = STAMINA
	sprint_timer.stop()

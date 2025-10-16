extends PhysicsBody2D

var velocity
const SPEED = 300
@onready var animated_sprite = $AnimatedSprite2D

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
		animated_sprite.play("walk")
	else:
		animated_sprite.play("default")
		
	if sprint and (x_dir or y_dir):
		animated_sprite.speed_scale = 2.0
		velocity = velocity * 2
	else:
		animated_sprite.speed_scale = 1.0
	
	move_and_collide(velocity)
	
	# locks character to rectangle from (0,0) to (sreen_size.x, screen_size.y)
	global_position = global_position.clamp(Vector2(0,0), screen_size)
	
	"""
	if collision_info:
		velocity = Vector2(0,0)
	if global_position.x < 0:
		global_position.x = 0
	if global_position.y < 0:
		global_position.y = 0
	if global_position.y > screen_size.y:
		global_position.y = screen_size.y
	if global_position.x > screen_size.x:
		global_position.x = screen_size.x
	-------------------------------------------  ^
	or we can use clamp / clampf() ______________|
	-------------------------------------------
	global_position.x = clampf(global_position.x, 0, screen_size.x)
	global_position.y = clampf(global_position.y, 0, screen_size.y)
	"""

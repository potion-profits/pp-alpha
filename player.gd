extends PhysicsBody2D

var velocity
var speed = 10
#var player_size = $AnimatedSprite2D.

func _physics_process(delta):
	var screen_size = get_viewport_rect().size
	velocity = Vector2(0,0)
	if Input.is_action_pressed("move_up"):
		velocity.y = -speed
	if Input.is_action_pressed("move_down"):
		velocity.y = speed
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
	if Input.is_action_pressed("move_right"):
		velocity.x = speed
	
	move_and_collide(velocity)
	
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
	-------------------------------------------
	or we can use clamp / clampf()
	-------------------------------------------
	global_position.x = clampf(global_position.x, 0, screen_size.x)
	global_position.y = clampf(global_position.y, 0, screen_size.y)
	"""

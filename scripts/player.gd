extends PhysicsBody2D

#the resource that will be used to make an inventory (player_inventory.tres)
@export var inv_resource: Inv
var inv: Inv

const SPEED = 150
const STAMINA = 25
const STAMINA_RECHARGE_RATE = 10

var velocity : Vector2
var stamina : float = STAMINA
@onready var animated_sprite :  = $AnimatedSprite2D
@onready var sprint_timer : = $SprintTimer

signal stamina_change

enum movement_state {
	IDLE,
	WALK,
	SPRINT
}

var current_state : movement_state = movement_state.IDLE

#sets up player inventory on each run
func _ready() -> void:
	inv = inv_resource.duplicate(true) #makes mutable
	$Inv_UI.inv = inv #links player inventory and respective ui

func _physics_process(delta : float)->void:
	# allow variable screen sizes
	var screen_size : Vector2 = get_viewport_rect().size
	# reset speed and sprint flag each tick
	velocity = Vector2(0,0)
	
	var stamina_delta : float = STAMINA_RECHARGE_RATE * delta
	
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
	
	var sprint : bool = Input.is_action_pressed("sprint")
	
	if x_dir or y_dir:
		if sprint and stamina > 0:
			current_state = movement_state.SPRINT
		else:
			current_state = movement_state.WALK
	else:
		current_state = movement_state.IDLE
	
	match current_state:
		movement_state.IDLE:
			animated_sprite.play("default")
			animated_sprite.speed_scale = 1.0
			if sprint_timer.is_stopped():
				stamina += stamina_delta
		movement_state.WALK:
			animated_sprite.play("walk")
			animated_sprite.speed_scale = 1.0
			if sprint_timer.is_stopped():
				stamina += stamina_delta
		movement_state.SPRINT:
			animated_sprite.play("walk")
			animated_sprite.speed_scale = 2.0
			velocity *= 2
			stamina -= 2 * stamina_delta
			if stamina < STAMINA and sprint_timer.is_stopped():
				sprint_timer.start(2.0)
	stamina = min(stamina, STAMINA)
	
	move_and_collide(velocity)
	
	stamina_change.emit(stamina)
	
	# locks character to rectangle from (0,0) to (sreen_size.x, screen_size.y)
	global_position = global_position.clamp(Vector2(0,0), screen_size)

func _on_sprint_timer_timeout() -> void:
	sprint_timer.stop()
	
#called to pick up an item and add to player inventory
func collect(item: InvItem) -> bool:
	return inv.insert(item)

#currently used to check that given node is a player, should probably be changed
func player()->void:
	pass

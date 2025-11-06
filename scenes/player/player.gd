extends PhysicsBody2D

#the resource that will be used to make an inventory (player_inventory.tres)
@export var inv_resource: Inv
var inv: Inv

const SPEED = 150
const DASH_MULT = 2.2
const DASH_DURATION = 0.17
const DASH_COOLDOWN = 0.5

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
var last_dir := "down"

#sets up player inventory on each run
func _ready() -> void:
	inv = inv_resource.duplicate(true) #makes mutable
	$Inv_UI.inv = inv #links player inventory and respective ui
	$Inv_UI.allow_hotkeys = true #allows 1-5 use for hotbar-like inv

func _physics_process(delta : float)->void:
	move(current_state, delta)
	move_and_collide(velocity)
	
func move(curr_state : movement_state, delta : float) -> void:
	match curr_state:
		movement_state.IDLE:
			get_movement_input(delta)
			animated_sprite.speed_scale = 1.0
		movement_state.WALK:
			get_movement_input(delta)
			animated_sprite.speed_scale = 1.0
		movement_state.DASH:
			animated_sprite.speed_scale = DASH_MULT

# Updated function for 8 directional movement
func get_movement_input(delta : float) -> void:
	velocity = Vector2.ZERO
	
	var x_dir : float = Input.get_axis("move_left", "move_right")
	var y_dir : float = Input.get_axis("move_up", "move_down")
	velocity = Vector2(x_dir, y_dir)
	
	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * SPEED * delta
		
		# Determine direction name for animation
		# Appends direction based on directional input
		var anim_dir := ""
		if y_dir < 0:
			anim_dir = "up"
		elif y_dir > 0:
			anim_dir = "down"
		
		if x_dir < 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
			animated_sprite.flip_h = false
		elif x_dir > 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
			animated_sprite.flip_h = true
		
		last_dir = anim_dir

		var sprint := Input.is_action_just_pressed("sprint")
		if sprint and dash_cooldown.is_stopped():
			dash_duration.start(DASH_DURATION)
			velocity *= DASH_MULT
			current_state = movement_state.DASH
		else:
			current_state = movement_state.WALK

		if anim_dir != "":
			if animated_sprite.sprite_frames.has_animation("walk_" + anim_dir):
				animated_sprite.play("walk_" + anim_dir)
			else:
				animated_sprite.play("walk")
	else:
		current_state = movement_state.IDLE
		if animated_sprite.sprite_frames.has_animation("idle_" + last_dir):
			animated_sprite.play("idle_" + last_dir)
		else:
			animated_sprite.play("default")



func _on_dash_cooldown_timeout() -> void:
	dash_cooldown.stop()

func _on_dash_duration_timeout() -> void:
	dash_duration.stop()
	current_state = movement_state.IDLE
	dash_cooldown.start(DASH_COOLDOWN)
	
#called to pick up an item and add to player inventory
func collect(item: InvItem) -> bool:
	return inv.insert(item)

#currently used to check that given node is a player, should probably be changed
func player()->void:
	pass
	
func save()->void:
	ResourceSaver.save(inv, inv_resource.resource_path)

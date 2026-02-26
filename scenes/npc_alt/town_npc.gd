class_name TownNpc extends Npc

## This class represents an NPC that will spawn within the town scene

## Represents the last direction of the NPC
var last_dir : String = "up"
var floor_map : Node2D
var target: Vector2

var is_moving : bool = false
var bounced : bool = false
## Represents the astar path of the NPC
var current_path : Array = []
## Represents the current index of the NPC's path
var path_index : int = 0

const SPEED : int = 100
const roam_min : float = 3
const roam_max : float = 7

var time_elapsed : float = 0
var roam_timeout : float = randf_range(roam_min, roam_max)
var collision : KinematicCollision2D

func _ready() -> void:
	super._ready()
	var starting_dir : int = randi_range(0, directions.size()-1)
	var starting_flipped : bool = randi_range(0,1)
	last_dir = directions[starting_dir]
	sprite.flip_h = starting_flipped
	

func rand_move() -> void:
	var off1 : int = randi_range(-20,20)
	var off2 : int = randi_range(-20,20)
	target = self.position + Vector2(off1, off2)

func _process(delta: float) -> void:
	time_elapsed += delta
	
	if time_elapsed >= roam_timeout and not is_moving:
		is_moving = true
		rand_move()
		roam_timeout = randf_range(roam_min, roam_max)
	
	if time_elapsed >= roam_timeout and is_moving:
		roam_timeout = randf_range(roam_min, roam_max)
		is_moving = false
		time_elapsed = 0
		velocity = Vector2.ZERO
		bounced = false
	
	if is_moving:
		move_to_point()
	
	animate(velocity.x, velocity.y)

## Animates the NPC based on velocity determined by movement along path
func animate(x_dir: float, y_dir : float) -> void:
	var anim_dir := ""
	if Vector2(x_dir, y_dir) != Vector2.ZERO:
		if y_dir < 0:
			anim_dir = "up"
		elif y_dir > 0:
			anim_dir = "down"
		
		if x_dir < 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
				sprite.flip_h = false
		elif x_dir > 0:
			if anim_dir == "":
				anim_dir = "left"
			else:
				anim_dir += "left"
				sprite.flip_h = true
		
		last_dir = anim_dir
		
		if anim_dir != "":
			if sprite.sprite_frames.has_animation("walking_" + anim_dir):
				sprite.play("walking_" + anim_dir)
	else:
		if sprite.sprite_frames.has_animation("idle_" + last_dir):
			sprite.play("idle_" + last_dir)

func move_to_point() -> void:
	if target == null:
		return
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		roam_timeout -= 0.5
		bounced = true
	if not bounced:
		var direction: Vector2 = (target-self.position)
		var distance : float = direction.length()
		if distance < 2:
			velocity = Vector2.ZERO
			is_moving = false
			return
		velocity = direction.normalized()
	collision = move_and_collide(velocity)

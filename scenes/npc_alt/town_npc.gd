class_name TownNpc extends Npc

## This class represents an NPC that will spawn within the town scene


@onready var wait_time: Timer = $wait_time

## Represents the last direction of the NPC
var last_dir : String = "up"
var floor_map : Node2D
var target: Vector2

var is_moving : bool = false

## Represents the astar path of the NPC
var current_path : Array = []
## Represents the current index of the NPC's path
var path_index : int = 0

const SPEED : int = 100
const roam_min : float = 5
const roam_max : float = 10

var time_elapsed : float = 0
var roam_timeout : float = randf_range(roam_min, roam_max)

func _ready() -> void:
	super._ready()

func rand_move() -> void:
	var off1 : int = randi_range(-100,100)
	var off2 : int = randi_range(-100,100)
	target = self.position + Vector2(off1, off2)

func _process(delta: float) -> void:
	time_elapsed += delta
	
	if time_elapsed >= roam_timeout and not is_moving:
		is_moving = true
		rand_move()
		roam_timeout = randf_range(roam_min, roam_max)
		move_to_point()
		roam_timeout = randf_range(roam_min, roam_max)
		time_elapsed = 0
		is_moving = false

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
	velocity = (target - self.position).normalized() * SPEED
	move_and_slide()

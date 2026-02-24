class_name TownNpc extends Npc

## This class represents an NPC that will spawn within the town scene

## Represents the last direction of the NPC
var last_dir : String = "up"


func _ready() -> void:
	super._ready()

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

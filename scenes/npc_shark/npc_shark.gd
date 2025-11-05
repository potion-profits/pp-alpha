extends PhysicsBody2D

@onready var animated_sprite :  = $AnimatedSprite2D

enum movement_state {
	IDLE
}

var current_state : movement_state = movement_state.IDLE
var last_dir := "down"

func _physics_process(_delta : float)->void:
	pass
	
	

extends Area2D

@export var animation_name: String = "default"  # Name of animation to play

#used to check the player that can interact
var player: PhysicsBody2D = null
#tracks if player can interact
var player_in_area:bool = false

var count:int = 0

@onready var animated_sprite: AnimatedSprite2D = get_parent().get_node("CauldronAnim")

#lets player interact if in the area
func _input(event: InputEvent) -> void:
	if player_in_area == true:	
		if event.is_action_pressed("interact"):
			pass

#tracks when player is in area and sets the player
func _on_interactable_area_body_entered(body: Node) -> void:
	if body.has_method("player"):
		player = body
		player_in_area = true

#tracks when player leaves area
func _on_interactable_area_body_exited(body : Node) -> void:
	if body.has_method("player"):
		player_in_area = false
		

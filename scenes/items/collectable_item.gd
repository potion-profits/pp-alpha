extends Area2D

#the item resource that this collectable represents
@export var item: InvItem

#used to check the player that can collect
var player: PhysicsBody2D = null

#tracks if player can collect
var player_in_area:bool = false

#lets player collect if in the area
func _input(event: InputEvent) -> void:
	if player_in_area == true:	
		if event.is_action_pressed("interact"):
			player_collect()

#tracks when player is in area and sets the player
func _on_interactable_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		player_in_area = true

#tracks whent player leaves area
func _on_interactable_area_body_exited(body : Node) -> void:
	if body.is_in_group("player"):
		player_in_area = false

#tries making player collect and frees from scene if successful (inventory has space)
func player_collect()->void:
	if player.collect(item):
		get_parent().queue_free()

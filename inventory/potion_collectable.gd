extends Area2D

@export var item: InvItem
var player: PhysicsBody2D = null
var player_in_area:bool = false


func _input(event: InputEvent) -> void:
	if player_in_area == true:	if event.is_action_pressed("interact"):
		player_collect()
		print("+1 potion")
			

func _on_interactable_area_body_entered(body: Node) -> void:
	print("player entered")
	if body.has_method("player"):
		player = body
		player_in_area = true
		
func _on_interactable_area_body_exited(body : Node) -> void:
	if body.has_method("player"):
		print("Player out of area")
		player_in_area = false

func player_collect()->void:
	player.collect(item)
	await get_tree().process_frame
	get_parent().queue_free()

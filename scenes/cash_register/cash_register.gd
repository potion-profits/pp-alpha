extends Node2D

var player: Player
var curr_npc : Npc


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and curr_npc and player and not curr_npc.is_checked_out:
		curr_npc.is_checked_out = true
		curr_npc.checkout_timer.timeout.emit()
		print("YOU SOLD SOMETHING!!!!!\n")
		player.set_chips(50)


func _on_interactable_body_entered(body: Node2D) -> void:
	print(body.name)
	if body is Player:
		print("Player in")
		player = body
	if body is Npc and body.current_action == body.action.CHECKOUT and not body.is_checked_out:
		print("NPC in")
		curr_npc = body


func _on_interactable_body_exited(body: Node2D) -> void:
	print(body.name)
	if body is Player:
		print("Player out")
		player = null
	if body is Npc and body.current_action == body.action.LEAVE:
		print("NPC out")
		curr_npc = null

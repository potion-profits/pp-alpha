extends Node2D

var player: Player
var curr_npc : Npc


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and curr_npc and player and not curr_npc.is_checked_out:
		curr_npc.is_checked_out = true
		curr_npc.checkout_timer.timeout.emit()
		print("+50 gold\n")
		player.set_coins(50)


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
	if body is Npc and body.current_action == body.action.CHECKOUT and not body.is_checked_out:
		curr_npc = body


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
	if body is Npc and body.current_action == body.action.LEAVE:
		curr_npc = null

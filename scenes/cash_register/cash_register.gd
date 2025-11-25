extends Node2D

var player_in : bool = false
var npc_ready : bool = false


func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in = true
	if body is Npc and body.current_action == :
		
	pass # Replace with function body.

extends Area2D

#used to check the player that can interact
var player: PhysicsBody2D = null
#tracks if player can interact
var player_in_area:bool = false
var shelf_ui: CanvasLayer

# For now, just toggling visibility. WILL CHANGE
func _ready() -> void:
	shelf_ui =  get_node("../ui_layer")
	shelf_ui.visible = false
	
func _input(event: InputEvent) -> void:
	if player_in_area == true and event.is_action_pressed("interact"):
		if shelf_ui.visible:
			shelf_ui.visible = false
		else:
			shelf_ui.visible = true

#tracks when player is in area and sets the player
func _on_interactable_area_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body
		player_in_area = true

#tracks when player leaves area
func _on_interactable_area_body_exited(body : Node) -> void:
	if body.name == "Player":
		player_in_area = false

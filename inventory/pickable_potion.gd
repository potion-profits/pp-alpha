extends Node2D

var player_in_area : bool = false

var potion : PackedScene = preload("res://scenes/pickable_potion.tscn")
var player : Node = null


@export var item: InvItem

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if player_in_area == true:
		if event.is_action_pressed("interact"):
			pick_up()

func pick_up()->void:
	var potion_instance : Node = potion.instantiate()
	get_parent().add_child(potion_instance)
	player.collect(item)
	print("Player picked up potion")
	
func _on_pickable_area_body_entered(body: Node) -> void:
	if body.has_method("player"):
		print("Player in area")
		player_in_area = true
		player = body
		
func _on_pickable_area_body_exited(body : Node) -> void:
	if body.has_method("player"):
		print("Player out of area")
		player_in_area = false
	

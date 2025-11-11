extends Node2D

#this really does nothing but brings up text on how to interact
@onready var interact_label: Label = $InteractLabel

#used to sort closest interactable thing
var current_interactions :Array = []
var can_interact :bool = true

func _ready() -> void:
	interact_label.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			interact_label.hide()
			
			await current_interactions[0].interact.call()
			
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)
		if current_interactions[0].is_interactable:
			interact_label.text = current_interactions[0].interact_name
			interact_label.show()
	else:
		interact_label.hide()

func _sort_by_nearest(area1: Area2D, area2:Area2D) -> bool:
	var area1_dist:float = global_position.distance_to(area1.global_position)
	var area2_dist:float = global_position.distance_to(area2.global_position)
	return area1_dist < area2_dist

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)


func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)

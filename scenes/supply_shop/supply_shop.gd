extends Node2D

@onready var entity_manager: EntityManager = $EntityManager
@onready var cashier_npc: CharacterBody2D = $EntityManager/CashierNpc

func _ready() -> void:
	for child in entity_manager.get_children():
		if child is Npc or child is Player:
			continue
		var interactable : = child.get_node("Interactable")
		interactable.interact = func() -> void: pass
	
	cashier_npc.interactable.interact = open_purchase_scene

func open_purchase_scene() -> void:
	# link to Ozcar's code here
	pass

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")

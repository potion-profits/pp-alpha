extends Node2D

@onready var entities: Node2D = $Entities
@onready var cashier_npc: CharacterBody2D = $Entities/CashierNpc

func _ready() -> void:
	for child in entities.get_children():
		if child is Npc or child is Player:
			continue
		# only runs in debug mode according to Godot
		# ensures that non entities besides player and cashier are children of entity manager
		assert(child is Entity, "remove all non entities from entity manager besides player/npc")
		var interactable : = child.get_node("Interactable")
		interactable.interact = func() -> void: pass
		interactable.tooltip = ""
		update_sprite(child)
	
	cashier_npc.interactable.interact = open_purchase_scene

func open_purchase_scene() -> void:
	# link to Ozcar's code here
	SceneManager.change_to("res://scenes/town_menu/town_menu.tscn")
	pass

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		SceneManager.change_to("res://scenes/town/town.tscn")

func update_sprite(node : Entity) -> void:
	if node is Barrel:
		# target sprite atlas coords of random color
		var types : Array = ["red_barrel", "green_barrel", "blue_barrel", "dark_barrel"]
		node.change_barrel_color(types.pick_random())
	elif node is Crate:
		# select full crate from sprite atlas coords
		node.inv.slots[0].amount = node.MAX_AMT # initial amt for crate
		node.update_crate(true)
	else:
		# don't need to replace shelf or cauldron sprites
		# unless we want to swap lit cauldron sprite for unlit sprite
		pass

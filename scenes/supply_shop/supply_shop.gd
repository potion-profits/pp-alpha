extends Node2D

@onready var entities: Node2D = $Entities
@onready var cashier_npc: CharacterBody2D = $Entities/CashierNpc
@onready var spawn_marker: Marker2D = $PlayerSpawn
@onready var player: Player = $Entities/Player
@onready var dialogue_ui: CanvasLayer = $DialogueUI

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
	
	dialogue_ui.action_triggered.connect(_on_dialogue_action)
	cashier_npc.interactable.interact = open_shopkeeper_dialogue
	
	# Reopen dialogue if returning from a sub-scene
	if DialogueManager.dialogue_open:
		var file_key : String = DialogueManager.current_scene
		var dialogue_id : String = DialogueManager.current_dialogue_id
		dialogue_ui.open(file_key, dialogue_id)

func open_shopkeeper_dialogue() -> void:
	var last_dir: String = player.last_dir
	player.animated_sprite.play("idle_" + last_dir)
	player.set_physics_process(false)
	dialogue_ui.open("supply_shop", "shopkeeper_greeting")

func _on_dialogue_action(action: String, _data: Dictionary) -> void:
	var payload: Dictionary = {
		"with_transition": false
	}
	if action == "refill":
		SceneManager.change_to("res://scenes/refill_scene/backroom.tscn", payload)
	elif action == "storage":
		SceneManager.change_to("res://scenes/entity_storing/entity_storing.tscn", payload)
	elif action == "placement":
		SceneManager.change_to("res://scenes/grid_placement/grid_placement.tscn", payload)

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		var payload : Dictionary = SceneManager.get_payload()
		payload["player_position"] = spawn_marker.global_position
		SceneManager.change_to("res://scenes/town/town.tscn", payload)

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

extends Entity	#will help store placement and inventory information for persistence

var player_inv: Inv

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable

#shelf specific references
@onready var ui_layer: CanvasLayer = $Inv_UI_Layer
#@onready var player_ui: Control = $Inv_UI_Layer/Shelf_UI/NinePatchRect/ShelfContainer
@onready var shelf_ui: Control = $Inv_UI_Layer/Shelf_UI

func _ready()-> void:
	#links interactable template to shelf specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "shelf"
	
	# the shelf inventory will be treated as one array (player 0-4, shelf rest)
	if !inv:
		inv = Inv.new(12)
	
	#var player:Player = get_tree().get_first_node_in_group("player")
	#player_inv = player.get_inventory()
	#shelf_ui.set_inventories(player_inv, inv)
	#links inventories and respective ui
	#shelf_ui.inv = inv
	_debug_set_shelf_inv()
	# visibility instead controlled by interaction and ui layer
	#shelf_ui.open()

#Handles player interaction with shelf when appropriate
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player_inv = player.get_inventory()
	#makes sure interaction is from a player
	#when ui open, ensure player can not move (or pause scene)
	if player:
		if ui_layer.visible:
			player.open_other_ui(false)
			ui_layer.visible = false
		else:
			player.open_other_ui(true)
			ui_layer.visible = true
			# Assign the player's inventory to the UI
			shelf_ui.set_inventories(player_inv, inv)

func _debug_set_shelf_inv()->void:
	#var bottle:InvItem = InvItem.new()
	#bottle.setup_item("empty_bottle", "item_empty_bottle", 16, false, false)
	var green:InvItem = InvItem.new()
	green.setup_item("green_potion","item_green_potion", 4, true, false)
	#inv.insert(bottle)
	for i in range(5):
		inv.insert(green)

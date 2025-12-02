extends Entity	#will help store placement and inventory information for persistence

var player_inv: Inv

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable

@onready var collision : CollisionShape2D = $Collision

#shelf specific references
@onready var ui_layer: CanvasLayer = $Inv_UI_Layer
@onready var shelf_ui: Control = $Inv_UI_Layer/Shelf_UI

func _ready()-> void:
	#links interactable template to shelf specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "shelf"
	# create the shelf inventory 
	if !inv:
		inv = Inv.new(12)
	#_debug_set_shelf_inv()
	
#Handles player interaction with shelf when appropriate 
#ui visibility instead controlled by interaction
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
			#links both inventories and respective ui
			shelf_ui.set_inventories(player_inv, inv)
			
func get_inventory()->Array[InvSlot]:
	var tmp : Array[InvSlot] = []
	for item in inv.slots:
		if (!item):
			continue
		
		if (!item.item):
			continue
		
		tmp.append(item)
		
	return tmp;
	
func remove_item(item_code: String, quantity: int)->void:
	for i in range(inv.slots.size()):
		var slot: InvSlot = inv.slots[i]
		if(!slot or !slot.item):
			continue
		
		if (quantity <= 0):
			return
			
		if (slot.item.texture_code == item_code and slot.amount >= quantity):
			slot.amount -= quantity
			if slot.amount <= 0:
				inv.slots[i].item = null
				inv.slots[i].amount = 0
				
			inv.update.emit()
			shelf_ui.update_slots()
			return
			

func _debug_set_shelf_inv()->void:
	var green:InvItem = ItemRegistry.new_item("item_green_potion")
	green.mixable = 0
	green.sellable = 1
	for i in range(5):
		inv.insert(green)

func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Npc:
		body.check_shelf(self)

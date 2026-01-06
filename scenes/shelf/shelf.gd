extends Entity	#will help store placement and inventory information for persistence

## Represents and maintains functionality of a shelf. 
##
## Primarily handles the use of shelf by both player and NPCs. Mainly includes
## data handling, the visual handling is dealt with in shelf_inv_ui script.

var player_inv: Inv	## Holds the inventory of the player
var queue : Array[Npc] = []	## Holds any NPCs that are waiting to check the shelf

## Reference to interactable area
@onready var interactable: Area2D = $Interactable	

## Reference to physics collision
@onready var collision : CollisionShape2D = $Collision

## Reference to this shelf's UI menu
@onready var shelf_ui: Control = $Inv_UI_Layer/Shelf_UI

# Sets up the shelf as an entity and gives it an inventory with 12 spaces
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
	
# Handles player interaction with shelf when appropriate 
# ui visibility instead controlled by interaction
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	#makes sure interaction is from a player
	#when ui open, ensure player can not move (or pause scene)
	if player:
		player_inv = player.get_inventory()
		if shelf_ui.visible:
			inv.lock = false
			clear_queue()
			player.open_other_ui(false)
			shelf_ui.visible = false
			player_inv.update.emit()
		else:
			inv.lock = true
			player.open_other_ui(true)
			shelf_ui.visible = true
			#links both inventories and respective ui
			shelf_ui.set_inventories(player_inv, inv)

## Returns the shelf's inventory slots that have an item
func get_inventory()->Array[InvSlot]:
	var tmp : Array[InvSlot] = []
	for slot in inv.slots:
		if (!slot):
			continue
		
		if (!slot.item):
			continue
		
		tmp.append(slot)
		
	return tmp;

## Removes the given quantity of the given item from the inventory.[br][br]
##
## Emits an [signal Inv.update] signal and updates the shelf ui.
## Takes [param item_code] to identify what type of item to remove. 
## Takes [param quantity] as the item's amount to remove from this shelf.
## See [member ItemRegistry.items].
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
			

# debug function to make 5 green potions in the shelf
func _debug_set_shelf_inv()->void:
	var green:InvItem = ItemRegistry.new_item("item_green_potion")
	green.mixable = 0
	green.sellable = 1
	for i in range(5):
		inv.insert(green)

# handles NPC entering the interact area.
# when there is a lock, the npc goes into a waiting queue
# otherwise they just check the shelf and enter the waiting queue if their item
# was not found
func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Npc:
		if(inv.lock):	# case when player is in the shelf
			queue.push_back(body)	# waiting queue
			return
		else:
			inv.lock = true
			body.check_shelf(self)
			if !body.item_found:
				queue.push_back(body)
			inv.lock = false

# Removes the NPC from the queue
func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Npc:
		var idx : int = queue.find(body)
		if (idx != -1):
			queue.pop_at(idx)

## Empties the queue and every NPC in the queue checks the shelf
func clear_queue()->void:
	var body: Npc = queue.pop_front()
	while(body):
		body.check_shelf(self)
		await get_tree().process_frame
		body = queue.pop_front()

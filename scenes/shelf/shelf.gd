extends Entity	#will help store placement and inventory information for persistence

## Represents and maintains functionality of a shelf. 
##
## Primarily handles the use of shelf by both player and NPCs. Mainly includes
## data handling, the visual handling is dealt with in shelf_inv_ui script.

var player_inv: Inv	## Holds the inventory of the player
var queue : Array[Npc] = []	## Holds any NPCs that are waiting to check the shelf
var inv_size: int = 12 ## The size of the shelf's inventory

## Reference to interactable area
@onready var interactable: Area2D = $Interactable	

## Reference to physics collision
@onready var collision : CollisionShape2D = $Collision

## Reference to this shelf's UI menu
@onready var shelf_ui: Control = $Inv_UI_Layer/Shelf_UI
@onready var potion_visual_root : Node2D = $ShelfPotions
var potion_visuals : Array[Sprite2D] = []
var fill_visuals : Array[Sprite2D] = []

# Mapping item_id -> rgb color for modulation
const visual_color_map = {
	"item_red_potion": Color(1, 0, 0, 1),
	"item_green_potion": Color(0, 1, 0, 1),
	"item_blue_potion": Color(0, 0, 1, 1),
	"item_dark_potion": Color(0, 0, 0, 1),
	"item_empty_bottle": Color(0, 0, 0, 0)
}

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
		inv = Inv.new(inv_size)
	#set up in world potion visuals
	init_visuals()
	update_visuals()

func init_visuals()->void:
	potion_visuals.resize(inv_size)
	fill_visuals.resize(inv_size)
	
	for i in range(inv_size):
		var cell:Node2D = potion_visual_root.get_node("Cell%d" % i)
		if cell:
			var potion_sprite:Sprite2D = cell.get_node("PotionSingle")
			var fill_sprite:Sprite2D = cell.get_node("Fill")
			if potion_sprite and fill_sprite:
				potion_visuals[i] = potion_sprite
				fill_visuals[i] = fill_sprite

# Handles player interaction with shelf when appropriate 
# ui visibility instead controlled by interaction
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player_inv = player.get_inventory()
	if player and !shelf_ui.visible:
		inv.lock = true
		player.close_inv_ui()
		shelf_ui.visible = true
		#links both inventories and respective ui on open
		shelf_ui.set_inventories(player_inv, inv)
	# close on "e" 
	elif shelf_ui.visible:
		close_shelf()
		
func _input(event: InputEvent) -> void:
	# close on "esc"
	if event.is_action_pressed("ui_cancel"):
		if shelf_ui.visible:
			close_shelf()

func close_shelf()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player_inv = player.get_inventory()
	if player:
		inv.lock = false
		clear_queue()
		player.open_inv_ui()
		shelf_ui.visible = false
		# sync inventories to ui on close
		player_inv.update.emit()
		get_viewport().set_input_as_handled()
		# update visual on close
		update_visuals()

# eventually will update on change (currently only on close and npc grabbing item)
func update_visuals()->void:
	if potion_visuals.is_empty() or inv == null:
		return
	#check every single inventory slot and sync as needed
	for i in range(inv_size):
		# get inventory item at index
		if potion_visuals[i] and fill_visuals[i]:
			var inv_slot : InvSlot = inv.slots[i]
			var has_item : bool = inv_slot != null and inv_slot.item != null
			potion_visuals[i].visible = has_item
			fill_visuals[i].visible = has_item
			
			# color based on texture_id (until custom colors added)
			if has_item:
				var texture_code:String = inv_slot.item.texture_code
				fill_visuals[i].modulate = visual_color_map[texture_code]
## Returns the shelf's inventory slots that have an item
func get_inventory()->Array[InvSlot]:
	var tmp : Array[InvSlot] = []
	for slot in inv.slots:
		if (!slot):
			continue
		tmp.append(slot)
		
	return tmp;
	
## Removes the given quantity from the given index of the inventory.[br][br]
##
## Emits an [signal Inv.update] signal and updates the shelf ui.
## Takes [param index] to locate the item to remove. 
## Takes [param quantity] as the item's amount to remove from this shelf.
## See [member ItemRegistry.items].
func remove_item(index:int, quantity: int)->void:
	var slot: InvSlot = inv.slots[index]
	if(!slot or !slot.item):
		return
	
	if (quantity <= 0):
		return
		
	slot.amount -= quantity
	if slot.amount <= 0:
		inv.slots[index].item = null
		inv.slots[index].amount = 0
	inv.update.emit()
	shelf_ui.update_slots()
	# when npc takes item
	update_visuals()
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
			body.check_shelf(self)	# First check
			if !body.item_found:	# If not found, waiting queue
				queue.push_back(body)
			inv.lock = false

# Removes the NPC that exited from the queue
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

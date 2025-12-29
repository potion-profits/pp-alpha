extends Entity	#will help store placement and inventory information for persistence

var player_inv: Inv

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable

@onready var collision : CollisionShape2D = $Collision

@onready var inv_size : int = 12

#shelf specific references
@onready var ui_layer: CanvasLayer = $Inv_UI_Layer
@onready var shelf_ui: Control = $Inv_UI_Layer/Shelf_UI
@onready var potion_visual_root : Node2D = $ShelfPotions
var potion_visuals : Array[Sprite2D] = []
var fill_visuals : Array[Sprite2D] = []

## Mapping item_id -> rgb color modulation
const visual_color_map = {
	"item_red_potion": Color(1, 0, 0, 1),
	"item_green_potion": Color(0, 1, 0, 1),
	"item_blue_potion": Color(0, 0, 1, 1),
	"item_dark_potion": Color(0, 0, 0, 1),
	"item_empty_bottle": Color(0, 0, 0, 0)
}

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
	_debug_set_shelf_inv()
	init_visuals()
	update_visuals()

func init_visuals()->void:
	potion_visuals.resize(inv_size)
	fill_visuals.resize(inv_size)
	
	for i in range(inv_size):
		var cell:Node2D = potion_visual_root.get_node("Cell%d" % i)
		if cell:
			var potion_sprite:Sprite2D = cell.get_node("PotionSingle%d" % i)
			var fill_sprite:Sprite2D = cell.get_node("Fill%d" % i)
			if potion_sprite and fill_sprite:
				potion_visuals[i] = potion_sprite
				fill_visuals[i] = fill_sprite

#handles player interaction with shelf when appropriate 
#ui open controlled by interaction
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player_inv = player.get_inventory()
	if player and !ui_layer.visible:
		player.close_inv_ui()
		ui_layer.visible = true
		#links both inventories and respective ui on open
		shelf_ui.set_inventories(player_inv, inv)
	# close on "e" 
	elif ui_layer.visible:
		close_shelf()
		
func _input(event: InputEvent) -> void:
	# close on "esc"
	if event.is_action_pressed("ui_cancel"):
		if ui_layer.visible:
			close_shelf()

func close_shelf()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	player_inv = player.get_inventory()
	if player:
		player.open_inv_ui()
		ui_layer.visible = false
		# sync inventories to ui on close
		player_inv.update.emit()
		get_viewport().set_input_as_handled()
		# update visual on close
		update_visuals()

# I do want this to eventually be more reactive (only update on change rather than checking every slot
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

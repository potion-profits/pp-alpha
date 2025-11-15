extends Entity

"""
Barrels are interactable entities. 

When created, but before instantiation, caller must 
define a barrel's barrel_type

On interact, if the player is holding an empty bottle, the bottle will
be filled with 100 ml of liquid from the barrel
"""
@onready var interactable : Area2D = $Interactable
@onready var barrel_sprite: Sprite2D = $BarrelSprite

const BARREL_SIZE = 16
const SHEET_PATH = "res://assets/interior/shop/all_barrels01.png"

# Mapping barrel_id -> idx on sheet
const barrel_color_map = {
	"empty_barrel" : 0,
	"red_barrel": 1,
	"green_barrel": 2,
	"blue_barrel": 3,
	"dark_barrel": 4
}

# Mapping barrel_id -> potion
const barrel_bottle_map = {
	"red_barrel": "item_red_potion",
	"green_barrel": "item_green_potion",
	"blue_barrel": "item_blue_potion",
	"dark_barrel": "item_dark_potion"
}

var ml :int = 1_000
var barrel_type : String = "red_barrel"


func _ready() -> void:	
	# Links interactable template to barrel specific method
	interactable.interact = _on_interact
	
	# Sets up entity info
	super._ready()
	
	# Used to find out what scene to place in entity manager
	entity_code = barrel_type
	change_barrel_color(barrel_type)

func change_barrel_color(barrel_id : String) -> void:
	var atlas_texture : AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = preload(SHEET_PATH)
	atlas_texture.region = Rect2(
						barrel_color_map[barrel_id] * BARREL_SIZE, 
						0,
						BARREL_SIZE,
						BARREL_SIZE)

	entity_code = barrel_id
	barrel_sprite.texture = atlas_texture
	

func _on_interact() -> void:
	if (ml <= 0):
		return
		
	var player : Player = get_tree().get_first_node_in_group("player")
	if player:
		var selected_slot : InvSlot = player.get_selected_slot()
		
		# Slot itself can be NULL (Player is not selecting anything)
		if (!selected_slot):
			return
		
		# Item in slot could be NULL (No item in the slot)
		if (!selected_slot.item):
			return
		
		print(selected_slot.item.texture_code)
		if (selected_slot.item.texture_code != "item_empty_bottle"):
			return
		
		print("Have an empty bottle")
		var new_bottle : InvItem = ItemRegistry.new_item(barrel_bottle_map[barrel_type]);
		
		if (selected_slot.amount > 1 && (player.has_empty_slot() || player.can_stack_item(new_bottle))):
			player.remove_from_selected()
			player.collect(new_bottle)
			ml -= 100
			
		elif (selected_slot.amount == 1):
			player.remove_from_selected()
			player.collect(new_bottle)
			ml -= 100
		
		# Check if barrel is empty
		if (ml <= 0):
			change_barrel_color("empty_barrel")
		

func to_dict() -> Dictionary:
	var barrel_state : Dictionary = {
		"barrel_id": entity_code,
		"ml": ml
	}
	barrel_state.merge(super.to_dict())
	
	return barrel_state
	
func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	

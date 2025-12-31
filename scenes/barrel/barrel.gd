extends Entity

"""
Barrels are interactable entities.

On interact, if the player is holding an empty bottle, the bottle will
be filled with 100 ml of liquid from the barrel
"""
@onready var interactable : Area2D = $Interactable
@onready var barrel_sprite: Sprite2D = $BarrelSprite
@onready var select_sprite: AnimatedSprite2D = $SelectionAnimation
@export var animation_name: String = "default"

const SPRITE_SIZE = 16
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
@export var barrel_type : String = "red_barrel"

func _ready() -> void:	
	# Links interactable template to barrel specific method
	interactable.interact = _on_interact
	
	# Sets up entity info
	super._ready()
	
	# Used to find out what scene to place in entity manager
	entity_code = "barrel"
	change_barrel_color(barrel_type)
	
	if (barrel_type == "empty_barrel"):
		ml = 0
	
	if (!inv):
		inv = Inv.new(0)


func change_barrel_color(barrel_id : String) -> void:
	var atlas_texture : AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = preload(SHEET_PATH)
	atlas_texture.region = Rect2(
						barrel_color_map[barrel_id] * SPRITE_SIZE, 
						0,
						SPRITE_SIZE,
						SPRITE_SIZE)
	barrel_type = barrel_id
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
		
		if (selected_slot.item.texture_code != "item_empty_bottle"):
			return
		
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
		"barrel_id": barrel_type,
		"ml": ml
	}
	barrel_state.merge(super.to_dict())
	
	return barrel_state
	
func from_dict(data : Dictionary) -> void:
	super.from_dict(data)
	barrel_type = data["barrel_id"]
	ml = data["ml"]
	

func highlight()->void:
	if select_sprite && select_sprite.sprite_frames.has_animation(animation_name):
		select_sprite.visible = true
		select_sprite.play(animation_name)

func un_highlight()->void:
	if select_sprite:
		select_sprite.visible = false
		select_sprite.stop()

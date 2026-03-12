extends Node

## ItemRegistry is used to access the default states of the inventory items.[br][br]
## This includes the texture mapping and the default state values.
## To spawn a new item with a default state, [method ItemRegistry.new_item] should be used

const icon_size = 16
var default_texture:AtlasTexture = null ## Used when no texture is found for a given code

var atlas: Texture2D	## Holds all the textures for the items (only potions for now)

## Mapping of item codes to sprite in [member atlas]
var item_icons := {
	"item_empty_bottle": Rect2(2*icon_size,3*icon_size,icon_size,icon_size),
	"item_red_potion": Rect2(2*icon_size,1*icon_size,icon_size,icon_size),
	"item_green_potion": Rect2(1*icon_size,1*icon_size,icon_size,icon_size),
	"item_dark_potion": Rect2(1*icon_size,2*icon_size,icon_size,icon_size),
	"item_blue_potion": Rect2(2*icon_size,2*icon_size,icon_size,icon_size)
}

## Mapping of item codes to [InvItem] attributes
var items:Dictionary = {
	"item_empty_bottle":{
		"max_stack_size":1,
		"mixable": false,
		"sellable": false,
		"texture_code": "item_empty_bottle",
		"sell_price": 0
	},
	"item_red_potion":{
		"max_stack_size":1,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_red_potion",
		"sell_price": 45	
	},
	"item_green_potion":{
		"max_stack_size":1,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_green_potion",
		"sell_price": 55
	},
	"item_blue_potion":{
		"max_stack_size":1,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_blue_potion",
		"sell_price": 70
	},
	"item_dark_potion":{
		"max_stack_size":1,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_dark_potion",
		"sell_price": 120
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas = preload("res://assets/interior/shop/all_bottles01.png")

## Creates and returns a new [InvItem] based on the given item code.[br][br]
## 
## Ensures that each item with this code will share the same attributes in all 
## scenes.
func new_item(code: String)->InvItem:
	var ret:InvItem = InvItem.new()
	ret.from_dict(items[code])
	return ret

## Returns the texture corresponding to the given item code.
func get_icon(code: String) -> AtlasTexture:
	if not item_icons.has(code):
		push_warning("Missing atlas region for item code: %s" %code)
		return default_texture
	var tex:= AtlasTexture.new()
	tex.atlas = atlas
	tex.region = item_icons[code]
	return tex

## Returns the sell price corresponding to the given item code
func get_item_price(code: String) -> int:
	if not items.has(code):
		push_warning("Missing item information for item code: %s" %code)
		return 0
	
	return items[code]["sell_price"]

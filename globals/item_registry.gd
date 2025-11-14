#ItemRegistry is used to access the default states of the inventory items
#this includes the texture mapping and the default state values
# to spawn a new item with a default state, ItemRegistry.new_item should be used
extends Node

const icon_size = 16
var default_texture:AtlasTexture = null

var atlas: Texture2D
var item_icons := {
	"item_empty_bottle": Rect2(2*icon_size,3*icon_size,icon_size,icon_size),
	"item_red_potion": Rect2(2*icon_size,1*icon_size,icon_size,icon_size),
	"item_green_potion": Rect2(1*icon_size,1*icon_size,icon_size,icon_size),
	"item_dark_potion": Rect2(1*icon_size,2*icon_size,icon_size,icon_size),
	"item_blue_potion": Rect2(2*icon_size,2*icon_size,icon_size,icon_size)
}

var items:Dictionary = {
	"item_empty_bottle":{
		"max_stack_size":16,
		"mixable": false,
		"sellable": false,
		"texture_code": "item_empty_bottle"
	},
	"item_red_potion":{
		"max_stack_size":8,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_red_potion"
	},
	"item_green_potion":{
		"max_stack_size":8,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_green_potion"
	},
	"item_blue_potion":{
		"max_stack_size":8,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_blue_potion"
	},
	"item_dark_potion":{
		"max_stack_size":8,
		"mixable": true,
		"sellable": false,
		"texture_code": "item_dark_potion"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas = preload("res://assets/interior/shop/all_bottles01.png")

func new_item(code: String)->InvItem:
	var ret:InvItem = InvItem.new()
	ret.from_dict(items[code])
	return ret

func get_icon(code: String) -> AtlasTexture:
	if not item_icons.has(code):
		push_warning("Missing atlas region for item code: %s" %code)
		return default_texture
	var tex:= AtlasTexture.new()
	tex.atlas = atlas
	tex.region = item_icons[code]
	return tex

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas = preload("res://assets/interior/shop/all_bottles01.png")


func get_icon(code: String) -> AtlasTexture:
	if not item_icons.has(code):
		push_warning("Missing atlas region for item code: %s" %code)
		return default_texture
	var tex:= AtlasTexture.new()
	tex.atlas = atlas
	tex.region = item_icons[code]
	return tex

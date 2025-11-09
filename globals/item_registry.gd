extends Node

var atlas: Texture2D
var item_icons := {
	"item_empty_bottle": Rect2(160-16,48,16,16)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atlas = preload("res://assets/interior/shop/shelfandpotion01.png")


func get_icon(code: String) -> AtlasTexture:
	if not item_icons.has(code):
		push_warning("Missing atlas region for item code: %s" %code)
		return null
	var tex:= AtlasTexture.new()
	tex.atlas = atlas
	tex.region = item_icons[code]
	return tex

extends Resource

class_name InvItem

#simple class to represent inventory item
@export var name: String = ""
@export var texture: AtlasTexture #texture that will be displayed in scenes

var mixable:bool = false
var sellable:bool = false

func _init(item_name: String, item_texture: AtlasTexture, can_mix:bool, can_sell:bool)->void:
	name = item_name
	texture = item_texture
	mixable = can_mix
	sellable = can_sell

func equals(item:InvItem)->bool:
	if item == null:
		return false
	return (name == item.name 
	&& texture == item.texture 
	&& mixable == item.mixable 
	&& sellable == item.sellable)

func _duplicate() -> InvItem:
	var new_item:InvItem = InvItem.new(name,texture, mixable, sellable)
	return new_item

extends Resource

class_name InvItem

#simple class to represent inventory item
@export var name: String = ""
@export var texture: AtlasTexture #texture that will be displayed in scenes
@export var max_stack_size: int
@export var mixable:bool = false
@export var sellable:bool = false

func _init(item_name: String, item_texture: AtlasTexture, stack_size:int, can_mix:bool, can_sell:bool)->void:
	name = item_name
	texture = item_texture
	max_stack_size = stack_size
	mixable = can_mix
	sellable = can_sell

func equals(item:InvItem)->bool:
	if item == null:
		return false
	return (name == item.name 
	and texture == item.texture 
	and max_stack_size == item.max_stack_size
	and mixable == item.mixable 
	and sellable == item.sellable)

func _duplicate() -> InvItem:
	var new_item:InvItem = InvItem.new(name,texture,max_stack_size, mixable, sellable)
	return new_item

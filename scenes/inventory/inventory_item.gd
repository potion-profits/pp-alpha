#InvItem.new and setup_item/from_dict should be used when the state of an item
#being moved/ made is unknown and could potentially be not default state
#otherwise use ItemRegistry to spawn a new item with the code.

extends Resource

class_name InvItem

#simple class to represent inventory item
@export var max_stack_size: int
@export var mixable:bool = false
@export var sellable:bool = false
@export var texture_code: String = ""

@export var texture: AtlasTexture #texture that will be displayed in scenes

func _init()->void:
	pass

func setup_item(item_code: String, stack_size:int, can_mix:bool, can_sell:bool)->void:
	texture_code = item_code
	texture = ItemRegistry.get_icon(item_code)
	max_stack_size = stack_size
	mixable = can_mix
	sellable = can_sell

func equals(item:InvItem)->bool:
	if item == null:
		return false
	return (texture_code == item.texture_code
	and max_stack_size == item.max_stack_size
	and mixable == item.mixable 
	and sellable == item.sellable)

func _duplicate() -> InvItem:
	var new_item:InvItem = InvItem.new()
	new_item.setup_item(texture_code,max_stack_size, mixable, sellable)
	return new_item

func from_dict(data: Dictionary)->void:
	texture_code = data["texture_code"]
	texture = ItemRegistry.get_icon(texture_code)
	max_stack_size = data["max_stack_size"]
	mixable = data["mixable"]
	sellable = data["sellable"]
	print("item created: " ,self.to_dict())

func to_dict()->Dictionary:
	return {
		"texture_code"=texture_code,
		"max_stack_size"=max_stack_size,
		"mixable"=mixable,
		"sellable"=sellable
	}

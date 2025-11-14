extends Resource

class_name InvItem

#simple class to represent inventory item
@export var name: String = ""
@export var max_stack_size: int
@export var mixable:bool = false
@export var sellable:bool = false
@export var texture_code: String = ""

@export var texture: AtlasTexture #texture that will be displayed in scenes

func _init()->void:
	pass

func setup_item(item_name: String, item_code: String, stack_size:int, can_mix:bool, can_sell:bool)->void:
	name = item_name
	texture_code = item_code
	print(texture_code)
	texture = ItemRegistry.get_icon(item_code)
	max_stack_size = stack_size
	mixable = can_mix
	sellable = can_sell

func equals(item:InvItem)->bool:
	if item == null:
		return false
	return (name == item.name 
	and texture_code == item.texture_code
	and max_stack_size == item.max_stack_size
	and mixable == item.mixable 
	and sellable == item.sellable)

func _duplicate() -> InvItem:
	var new_item:InvItem = InvItem.new()
	new_item.setup_item(name,texture_code,max_stack_size, mixable, sellable)
	return new_item

func from_dict(data: Dictionary)->void:
	name = data["name"]
	texture_code = data["texture_code"]
	texture = ItemRegistry.get_icon(texture_code)
	max_stack_size = data["max_stack_size"]
	mixable = data["mixable"]
	sellable = data["sellable"]
	print("item created: " ,self.to_dict())

func to_dict()->Dictionary:
	return {
		"name"=name,
		"texture_code"=texture_code,
		"max_stack_size"=max_stack_size,
		"mixable"=mixable,
		"sellable"=sellable
	}

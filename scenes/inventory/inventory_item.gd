#InvItem.new and setup_item/from_dict should be used when the state of an item
#being moved/ made is unknown and could potentially be not default state
#otherwise use ItemRegistry to spawn a new item with the code.
extends Resource

class_name InvItem

## Handles inventory item creation, saving/loading, and management.
##
## For the most part, creating items should go through the [ItemRegistry]. 
## Otherwise, functionality for checking equality, duplicating, 
## and saving/loading is provided in this class.

## The max number of this type of item that can stack
@export var max_stack_size: int	
## The mixed state (mostly for potions)
@export var mixable:bool = false	
## The sellable state (only able to sell mixed potions)
@export var sellable:bool = false	
## Identifies the item. See [member ItemRegistry.items].
@export var texture_code: String = ""	
## Holds the texture of the item
@export var texture: AtlasTexture

func _init()->void:
	pass

## Used as an explicit constructor. 
## Sets this instance's attributes to those given. 
func setup_item(item_code: String, stack_size:int, can_mix:bool, can_sell:bool)->void:
	texture_code = item_code
	texture = ItemRegistry.get_icon(item_code)
	max_stack_size = stack_size
	mixable = can_mix
	sellable = can_sell

## Checks that this item has the same attributes as the given item. 
## Returns true if all attributes are the same. [br][br]
## Takes [param item] as the inventory item to compare to. 
func equals(item:InvItem)->bool:
	if item == null:
		return false
	return (texture_code == item.texture_code
	and max_stack_size == item.max_stack_size
	and mixable == item.mixable 
	and sellable == item.sellable)

# Copies all the attributes of this item to a new instance and returns the new item. 
func _duplicate() -> InvItem:
	var new_item:InvItem = InvItem.new()
	new_item.setup_item(texture_code,max_stack_size, mixable, sellable)
	return new_item

## Reconstructs an instance of an item defined by [param data]. [br][br]
##
## Expects the following key/value pairs:[br]
## [code] "texture_code": String [/code], [br]
## [code] "max_stack_size": int [/code], [br]
## [code] "mixable": bool [/code], and[br]
## [code] "sellable": bool [/code] [br][br]
## See also [method to_dict].
func from_dict(data: Dictionary)->void:
	texture_code = data["texture_code"]
	texture = ItemRegistry.get_icon(texture_code)
	max_stack_size = data["max_stack_size"]
	mixable = data["mixable"]
	sellable = data["sellable"]

## Creates and returns a dictionary of the defining characteristics of this item.[br][br]
## 
## Used to save the state of this item. See also [method from_dict].
func to_dict()->Dictionary:
	return {
		"texture_code"=texture_code,
		"max_stack_size"=max_stack_size,
		"mixable"=mixable,
		"sellable"=sellable
	}

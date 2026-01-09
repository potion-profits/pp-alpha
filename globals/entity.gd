extends StaticBody2D

class_name Entity

## Entities are special Static Bodies that are 
## preserved through the game state. [br][br]
## 
## Entities are identified by their entity code, may optionally have an inventory, 
## and have methods to aid in storing their data for saving/loading the game state.

## Identifying code for each entity. See [member EntityManager.entity_codes].
@export var entity_code: String 

var inv: Inv ## Inventory that this entity has (may not have one)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("entity")

## Creates and returns a dictionary of the defining characteristics of this entity.[br][br]
## 
## The data stored is the identifying code, the position, and any inventory it may have.
func to_dict()-> Dictionary:
	return{
		"entity_code":entity_code,
		"x_pos": global_position.x,
		"y_pos": global_position.y,
		"inv": inv.to_dict() if inv else {}
	}

## Reconstructs an entity with the given information.[br][br]
##
## Takes [param data] and expects it to contain:[br]
## [code] "entity_code": String [/code], [br]
## [code] "x_pos": float [/code], [br]
## [code] "y_pos":float [/code], [br]
## [code] "inv": Dictionary [/code]
func from_dict(data:Dictionary)->void:
	entity_code = data["entity_code"]
	global_position = Vector2(data["x_pos"], data["y_pos"])
	var inv_data:Dictionary = data["inv"]
	if inv_data:
		inv = Inv.new()
		inv.from_dict(inv_data)

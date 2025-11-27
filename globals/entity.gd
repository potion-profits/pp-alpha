extends StaticBody2D

class_name Entity

@export var entity_code: String
var inv: Inv

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("entity")


func to_dict()-> Dictionary:
	return{
		"entity_code":entity_code,
		"x_pos": global_position.x,
		"y_pos": global_position.y,
		"inv": inv.to_dict() if inv else {}
	}


func from_dict(data:Dictionary)->void:
	entity_code = data["entity_code"]
	global_position = Vector2(data["x_pos"], data["y_pos"])
	var inv_data:Dictionary = data["inv"]
	if inv_data:
		inv = Inv.new()
		inv.from_dict(inv_data)

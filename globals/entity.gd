extends StaticBody2D

class_name Entity

var res_uid: int
@export var scene_uid: String
@export var inv_resourse: Inv

var inv: Inv

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("entity")
	if not res_uid:
		res_uid = ResourceUID.create_id()
	if inv_resourse:
		inv = inv_resourse.duplicate(true)
	


func to_dict()-> Dictionary:
	return{
		"res_uid":res_uid,
		"scene_uid":scene_uid,
		"x_pos": global_position.x,
		"y_pos": global_position.y,
		"inv_id": inv.db_id if inv else null
	}


func from_dict(data:Dictionary)->void:
	res_uid = data["res_uid"]
	scene_uid = data["scene_uid"]
	global_position = Vector2(data["x_pos"], data["y_pos"])
	if inv_resourse:
		inv = inv_resourse.duplicate(true)
	#var inv_id:int = data["inv_id"]
	#if inv_id:
		#inv.load(inv_id)

extends Entity

func _ready()-> void:
	super._ready()
	scene_uid = "res://scenes/cauldron/cauldron.tscn"

func save()->void:
	save_to_db()

func load_inv_from_db(_id:String)->void:
	pass
	
func save_to_db()->void:
	pass
	
	

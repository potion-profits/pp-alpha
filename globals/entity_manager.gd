extends Node
class_name EntityManager

func load_from_dict(data:Dictionary)->void:
	var entity_scene : PackedScene = load(data["scene_uid"])
	var entity: Entity = entity_scene.instantiate() as Entity
	entity.from_dict(data)
	add_child(entity)
		

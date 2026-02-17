extends Node
class_name EntityManager

## Handles loading a new instance of an [Entity] into the scene tree. [br][br]
##
## Maintains all the possible entity codes that correspond to loadable entities. 
## Has a method to load an Entity into the scene tree from a dictionary.

## All valid entity codes and their corresponding scene
var entity_codes:Dictionary = {
	"cauldron": "res://scenes/cauldron/cauldron.tscn",
	"shelf": "res://scenes/shelf/shelf.tscn",
	"crate": "res://scenes/crate/crate.tscn",
	"barrel": "res://scenes/barrel/barrel.tscn",
	"bed": "res://scenes/bed/bed.tscn"
}

## Creates an in game representation of an Entity given it's data.[br][br]
##
## Takes [param data] and expects a valid entity code. [br][br]
## See [member entity_codes] and [method Entity.from_dict].
func load_from_dict(data:Dictionary)->void:
	var entity: Entity = create_entity(data["entity_code"])
	entity.from_dict(data)
	add_child(entity)

## Creates and returns an instance of an Entity given the proper entity code.[br][br]
##
## Takes [param entity_code] and expects it to be valid. See [member entity_codes].
func create_entity(entity_code: String) -> Entity:
	var entity_scene : PackedScene = load(entity_codes[entity_code])
	var entity: Entity = entity_scene.instantiate() as Entity
	return entity

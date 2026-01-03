extends Node

## Interface to easily manage scene transitions and common scene structures. [br][br]
## 
## Allows for changing scenes while maintaining game state, 
## passing payloads between scenes, receiving payloads,
## and getting the current scene.

## Holds any information that the previous scene wants the new scene to have.
var scene_payload : Dictionary = {}

## Unloads current scene and loads given scene.[br][br]
##
## Saves current scenes state, stores the payload, prepares to load the next scene, and changes the scene.[br][br]
##
## Takes [param scene_path] as file path to the scene[br]
## Optionally takes [param payload] as a dictionary of information to be passed[br]
func change_to(scene_path: String, payload : Dictionary = {}) -> void:
	var cs:Node = get_tree().current_scene
	if cs:
		GameManager.save_scene_runtime_state(cs.name) # save state

	scene_payload = {}	# in case payload was not consumed
	scene_payload = payload	# save given payload
	GameManager.connect_scene_load_callback()	# ready to load next scene's state
	get_tree().call_deferred("change_scene_to_file", scene_path)	# change the scene when possible

## Consumes and returns the current payload. [br][br]
## 
## Ensures that the once the payload is used, it wont be used again.
## Expected to only be called once because the payload is destroyed at each call.
func get_payload() -> Dictionary:
	var payload: Dictionary = scene_payload
	scene_payload = {}
	return payload

## Returns the current scene as a node. [br][br]
##
## Synonamous to [code] get_tree().current_scene [/code]
func current_scene() -> Node:
	return get_tree().current_scene

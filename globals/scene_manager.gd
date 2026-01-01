extends Node

var scene_payload : Dictionary = {}

func change_to(scene_path: String, payload := {}) -> void:
	var cs:Node = get_tree().current_scene
	if cs:
		GameManager.save_scene_runtime_state(cs.name)
	
	scene_payload = {}
	scene_payload = payload
	GameManager.connect_scene_load_callback()
	get_tree().call_deferred("change_scene_to_file", scene_path)

func get_payload() -> Dictionary:
	var payload: Dictionary = scene_payload
	scene_payload = {}
	return payload

func current_scene() -> Node:
	return get_tree().current_scene

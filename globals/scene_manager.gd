extends Node

## Interface to easily manage scene transitions and common scene structures. [br][br]
## 
## Allows for changing scenes while maintaining game state, 
## passing payloads between scenes, receiving payloads,
## and getting the current scene.

@onready var shop_path : String = "res://scenes/player_shop/main_shop.gd"

## Holds any information that the previous scene wants the new scene to have.
var scene_payload : Dictionary = {}
## Holds last known position of character for each scene they loaded into in a session
var last_known_positions : Dictionary = {}

signal scene_ready

func _ready() -> void:
	TimeManager.day_end.connect(_on_day_end)
	get_tree().scene_changed.connect(_on_scene_changed)

## Unloads current scene and loads given scene.[br][br]
##
## Saves current scenes state, stores the payload, prepares to load the next scene, and changes the scene.[br][br]
##
## Takes [param scene_path] as file path to the scene[br]
## Optionally takes [param payload] as a dictionary of information to be passed[br]
func change_to(scene_path: String, payload : Dictionary = {}) -> void:
	save_player_position() # save position before leaving
	GameManager.save_scene_runtime_state() # save state
	scene_payload = {}	# in case payload was not consumed
	scene_payload = payload	# save given payload
	GameManager.connect_scene_load_callback()	# ready to load next scene's state
	get_tree().call_deferred("change_scene_to_file", scene_path)	# change the scene when possible
	MusicManager.play_bg_music(scene_path) # play the relevant song for the new scene

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

## Adds player's last position when loading out of scene
func save_player_position() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	var pos_offset : Vector2 = Vector2(0, 5)
	if player:
		var scene_name: StringName = get_tree().current_scene.name
		last_known_positions[scene_name] = player.global_position - pos_offset

## Loads player's last known position (if applicable) of scene they are loading into
func load_player_position() -> void:
	var player : Player = get_tree().get_first_node_in_group("player")
	if player:
		var scene_name: StringName = get_tree().current_scene.name
		if last_known_positions.has(scene_name):
			player.global_position = last_known_positions[scene_name]
		if scene_name != "Town":
				player.last_dir = "up"
				player.animated_sprite.play("idle_up")

func _on_day_end() -> void:
	get_tree().change_scene_to_file(shop_path)
	print("scene changed to:")
	print(current_scene())

func _on_scene_changed() -> void:
	print("scene is ready")
	scene_ready.emit()	

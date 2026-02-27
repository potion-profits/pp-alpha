extends Node
## Interface to easily manage scene transitions and common scene structures.
##
## Allows for changing scenes while maintaining game state, 
## passing payloads between scenes, receiving payloads,
## and getting the current scene.

## Holds any information that the previous scene wants the new scene to have.
var scene_payload: Dictionary = {}
## Holds last known position of character for each scene they loaded into in a session
var last_known_positions: Dictionary = {}
## Holds last known scene file path
var last_known_scene: String

## Transition overlay
var transition_layer: CanvasLayer
var transition_rect: ColorRect
## True while a transition is playing
var is_transitioning: bool = false

func _ready() -> void:
	# allows transition to persist between scenes
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_transition()

## Creates the transition overlay
func setup_transition() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100 # transition layer always 
	add_child(transition_layer)
	
	# creates transition overlay that lives only during transition
	# will cover whole screen
	transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(transition_rect)
	transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

## Plays fade out transition (transparent to black)
func fade_out(seconds: float = 0.5) -> void:
	is_transitioning = true
	get_tree().paused = true
	var tw: Tween = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(transition_rect, "color:a", 1.0, seconds)
	await tw.finished

## Plays fade in transition (black to transparent)
func fade_in(seconds: float = 0.5) -> void:
	var tw: Tween = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(transition_rect, "color:a", 0.0, seconds)
	await tw.finished
	get_tree().paused = false
	is_transitioning = false

## Unloads current scene and loads given scene.
##
## Saves current scenes state, stores the payload, prepares to load the next scene, 
## and changes the scene.
##
## Takes [param scene_path] as file path to the scene
## Optionally takes [param payload] as a dictionary of information to be passed
## Optionally takes [param with_transition] to enable/disable fade transition
func change_to(scene_path: String, payload: Dictionary = {}, with_transition: bool = true) -> void:
	GameManager.save_scene_runtime_state()
	scene_payload = payload
	# Save position before leaving
	if payload.has("player_position"):
		save_player_position(payload["player_position"])
	else:
		save_player_position()
	last_known_scene = current_scene().scene_file_path
	GameManager.connect_scene_load_callback()
	if with_transition:
		await fade_out(0.5)
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", scene_path)
	MusicManager.play_bg_music(scene_path)
	if with_transition:
		await get_tree().tree_changed
		await get_tree().process_frame
		fade_in(0.5)

## Consumes and returns the current payload.
## 
## Ensures that once the payload is used, it wont be used again.
## Expected to only be called once because the payload is destroyed at each call.
func get_payload() -> Dictionary:
	var payload: Dictionary = scene_payload
	scene_payload = {}
	return payload

## Returns the current scene as a node.
##
## Synonamous to [code] get_tree().current_scene [/code]
func current_scene() -> Node:
	return get_tree().current_scene

## Saves player's last position when loading out of scene
func save_player_position(player_pos: Vector2 = Vector2.ZERO) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		var scene_name: StringName = current_scene().name
		if player_pos != Vector2.ZERO:
			last_known_positions[scene_name] = player_pos
		else:
			last_known_positions[scene_name] = player.global_position

## Loads player's last known position (if applicable) of scene they are loading into
func load_player_position() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		var scene_name: StringName = current_scene().name
		if last_known_positions.has(scene_name):
			player.global_position = last_known_positions[scene_name]

extends Node
## Interface to easily manage scene transitions and common scene structures. [br][br]
##
## Allows for changing scenes while maintaining game state, 
## passing payloads between scenes, receiving payloads,
## and getting the current scene.

@onready var shop_path : String = "res://scenes/player_shop/main_shop.tscn"
var pausable_scenes : Array = [
	'res://scenes/casino/casino_floor.tscn',
	'res://scenes/town/town.tscn',
	'res://scenes/supply_shop/supply_shop.tscn',
	'res://scenes/player_shop/main_shop.tscn',
	'res://scenes/casino/casino_floor.tscn'
]
## Holds any information that the previous scene wants the new scene to have.
var scene_payload: Dictionary = {}

## Signal emitted after a scene has fully loaded AND fade-in is complete
signal scene_ready

## Holds last known position of character for each scene they loaded pinto in a session
var last_known_positions: Dictionary = {}
var last_known_scene: String = ""
var last_dir: String = ""
var last_flip_h: bool = false

## Transition overlay
var transition_layer: CanvasLayer
var transition_rect: ColorRect

## True while a transition is playing
var is_transitioning: bool = false
var with_transition: bool = true

## Menu scenes to not save
const menu_scenes : Array = [
	"res://scenes/cinematics/opening_logos.tscn",
	"res://scenes/ui/options_menu.tscn",
	"res://scenes/ui/start_menu.tscn",
	"res://scenes/ui/volume_menu.tscn",
	"res://scenes/ui/pause_menu.tscn",
	"res://scenes/ui/settings_menu.tscn"
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_transition()
	TimeManager.day_end.connect(_on_day_end)
	get_tree().scene_changed.connect(_on_scene_changed)

func setup_transition() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	add_child(transition_layer)

	transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(transition_rect)
	transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func fade_out(seconds: float = 0.5) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	is_transitioning = true
	var tw: Tween = create_tween()
	tw.tween_property(transition_rect, "color:a", 1.0, seconds)
	await tw.finished

func fade_in(seconds: float = 0.5) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	var tw: Tween = create_tween()
	tw.tween_property(transition_rect, "color:a", 0.0, seconds)
	await tw.finished
	is_transitioning = false
	player = get_tree().get_first_node_in_group("player")
	if player and not DialogueManager.dialogue_open:
		player.set_physics_process(true)

func change_to(scene_path: String, payload: Dictionary = {}) -> void:
	# Prevent double transitions
	if is_transitioning:
		return
	
	if GameManager.player_passed_out:
		with_transition = false
	else:
		with_transition = true
	
	GameManager.save_scene_runtime_state()
	scene_payload = payload.duplicate()
	
	handle_payload(payload)
	
	var cs : String = current_scene().scene_file_path
	if cs not in menu_scenes:
		last_known_scene  = cs
	GameManager.connect_scene_load_callback()
	
	## Fade out first
	if with_transition:
		await fade_out(0.5)

	# Change scene (deferred for safety)
	get_tree().call_deferred("change_scene_to_file", scene_path)
	MusicManager.play_bg_music(scene_path)
	
	if scene_path in pausable_scenes:
		if not GameManager.pause_menu.get_parent():
			call_deferred("add_child", GameManager.pause_menu)
		GameManager.call_deferred("unpause")
		GameManager.enable_pause()
	else:
		GameManager.disable_pause()

func get_payload() -> Dictionary:
	var payload : Dictionary = scene_payload
	scene_payload = {}
	return payload

func current_scene() -> Node:
	return get_tree().current_scene

func save_player_position(player_pos: Vector2 = Vector2.ZERO) -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		var scene_name: StringName = current_scene().name
		last_known_positions[scene_name] = (
			player_pos if player_pos != Vector2.ZERO else player.global_position
		)
		last_dir = player.last_dir
		last_flip_h = player.animated_sprite.flip_h 

func load_player_position() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	if player:
		var scene_name: StringName = current_scene().name
		
		if last_known_positions.has(scene_name) and last_known_positions[scene_name] != Vector2.ZERO:
			player.global_position = last_known_positions[scene_name]
		
		# load player facing direction from last scene
		if last_dir != "":
			player.last_dir = last_dir 
			player.animated_sprite.flip_h = last_flip_h
			if player.animated_sprite.sprite_frames.has_animation("idle_" + player.last_dir):
				player.animated_sprite.play("idle_" + player.last_dir)
		

func _on_day_end() -> void:
	await change_to(shop_path, {})
	last_known_positions = {}

func _on_scene_changed() -> void:
	# Wait one frame to ensure scene is fully ready
	await get_tree().process_frame
	if with_transition:
		await fade_in(0.5)
	if GameManager.player_passed_out:
		scene_ready.emit()

## Handles various payload keys
func handle_payload(payload: Dictionary) -> void:
	save_player_position() ## always save player global pos by default
	if not payload:
		return
	for key:String in payload:
		match key:
			"player_position":
				# overwrite player pos if given
				save_player_position(payload["player_position"])
			"with_transition":
				with_transition = payload["with_transition"]
			_: 
				continue
				

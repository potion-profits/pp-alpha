extends Node

## Handles the game state and any mechanics that persist throughout the game.
##
## Primarily handles saving/loading from both memory and disk. 
## Also handles unhandled inputs, which is used for the pause menu.

@onready var player_passed_out : bool = false

## The instance of the pause menu (likely will change)
var pause_menu: CanvasLayer = preload("res://scenes/ui/pause_menu.tscn").instantiate()
var runtime_entities:Dictionary = {} ## Holds all the entities in every scene. See [Entity].
var player_data:Dictionary = {}	## Holds the player's data. See [Player].
var tutorial_completed: bool = false ## Tutorial bool so only runs on first instance
var pause_enabled : bool = false
var credits_flag : bool  = false
var initial_play : bool = false


# PLEASE UPDATE THIS IF THE DEFAULT STATE NEEDS TO BE UPDATED
# format is MM.DD.YR/Version
const default_state_version: String = "3.05.26/1"

func _ready()->void:
	pause_menu.layer = 200
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_from_storage()
	# Load settings data from storage to apply all settings on game boot
	SettingSaveManager.load_settings_data()
	unpause()

func enable_pause()->void:
	pause_menu.hide()
	pause_menu.visible = false
	pause_enabled = true
	
func disable_pause() -> void:
	pause_menu.hide()
	pause_menu.visible = false
	pause_enabled = false

# Any input in this function will always behave as defined here unless 
# explicitly handled elsewhere
func _unhandled_input(event : InputEvent)->void:
	if SceneManager.is_transitioning:
		return
	if event.is_action_pressed("ui_cancel"):
		#Case where pausing is allowed
		if(pause_menu and pause_enabled and !SettingsMenu.visible):
			get_tree().paused = !get_tree().paused
			pause_menu.visible = get_tree().paused

## Unpauses the game by removing the pause menu.
func unpause()->void:
	if (pause_menu and pause_enabled):
		get_tree().paused = false
		pause_menu.hide()
		pause_menu.visible = false
		if not DialogueManager.dialogue_open:
			TimeManager.set_process(true)

## Commits everything in [member runtime_entities] and [member player_data] to disk.[br][br]
##
## Converts the in memory state to a json that is saved on the disk in a 
## file called [i]savegame.save[/i].
func commit_to_storage()->void:
	var save_payload:Dictionary = {
		"version": default_state_version,
		"player": player_data,
		"scenes": runtime_entities,
		"day": TimeManager.day
	}
	var json_text : String = JSON.stringify(save_payload, "\t")
	var file: FileAccess = FileAccess.open("user://savegame.save",FileAccess.WRITE)
	if file:
		file.store_string(json_text)
		file.flush()
		file.close()
		print("Game Saved.")
	else:
		push_error("Failed to open save file.")

## Loads the saved game state from disk into memory.[br][br]
##
## Takes the data from the savegame.save file or default_state 
## if no save has been made. 
func load_from_storage()->void:
	var save_file:FileAccess = null
	if not FileAccess.file_exists("user://savegame.save"):
		save_file = FileAccess.open("res://globals/default_state.txt", FileAccess.READ)
		initial_play = true
	else:
		save_file = FileAccess.open("user://savegame.save",FileAccess.READ)
	
	var json_text:String = save_file.get_as_text()
	save_file.close()
	
	var json:Variant = JSON.parse_string(json_text)
	if json == null:
		push_error("Failed to parse save file.")
		return
	
	if default_state_version != json.get("version", "") and FileAccess.file_exists("user://savegame.save"):
		print("Incorrect version, has ", json.get("version", "no version"), " but expects ", default_state_version)
		print("Using default state instead")
		save_file = FileAccess.open("res://globals/default_state.txt", FileAccess.READ)
		initial_play = true
		json_text = save_file.get_as_text()
		save_file.close()
		json = JSON.parse_string(json_text)
		if json == null:
			push_error("Failed to parse save file.")
			return
		
	runtime_entities = json["scenes"]
	player_data = json["player"]
	TimeManager.day = json['day']
	#print("Game Loaded with : ",player_data,"\n", runtime_entities)

## Stores current scene's and player's state into the runtime memory.[br][br]
##
## Ensures safe saving if possible. Scene name is used over Scene path to allow
## for different scenes to modify the same state. (Used for refills)
func save_scene_runtime_state() -> void:
	var cs:Node = SceneManager.current_scene()
	var scene_name: String = cs.name
	var em:EntityManager = null
	if cs.has_node("EntityManager"):
		em = cs.get_node("EntityManager")
	if em:
		runtime_entities[scene_name] = []
		for entity in em.get_children():
			if entity is Entity:
				runtime_entities[scene_name].append(entity.to_dict())
				#print("saved: ",entity.to_dict())
	var player_node: Node = cs.find_child("Player", true, false)
	if player_node:
		player_data = player_node.to_dict()
	
## Loads the current scene's and player's state from runtime memory.[br][br]
## 
## Ensures safe loading of entities and player data. See also [method save_scene_runtime_state].
func load_scene_runtime_state()->void:
	var cs:Node = SceneManager.current_scene()
	var player_node: Node = cs.find_child("Player", true, false)
	if player_node and player_data:
		player_node.from_dict(player_data)

	SceneManager.load_player_position()

	var em:EntityManager = null
	var scene_name:String = cs.name
	if cs.has_node("EntityManager"):
		em = cs.get_node("EntityManager")
	if em:
		for child in em.get_children():
			if child is Entity:
				child.queue_free()
	if em and runtime_entities.has(scene_name):
		for data:Dictionary in runtime_entities[scene_name]:
			em.load_from_dict(data)
			#print("loaded: ", data)
	
	if cs.has_node("DialogueUI"):
		var cs_dialogue : CanvasLayer = cs.get_node("DialogueUI")
		cs_dialogue.reopen_dialogue()

## Creates a callback to load the next scene's state. [br][br]
##
## Is used to change scenes easily. Changes the scene_changed signal to call 
## [method load_scene_runtime_state] which loads the new scene's state as it 
## gets instantiated. [br][br]
## Usage within [method SceneManager.change_to]:
## [codeblock]GameManager.save_scene_runtime_state()
## scene_payload = {}
## scene_payload = payload
## GameManager.connect_scene_load_callback()
## get_tree().call_deferred("change_scene_to_file", scene_path)[/codeblock]
func connect_scene_load_callback()->void:
	if not get_tree().is_connected("scene_changed", Callable(self, "load_scene_runtime_state")):
		get_tree().connect("scene_changed", Callable(self, "load_scene_runtime_state"), CONNECT_ONE_SHOT)


func delete_save()->void:
	var exists :bool = FileAccess.file_exists("user://savegame.save")
	if exists:
		DirAccess.remove_absolute("user://savegame.save")
	load_from_storage()

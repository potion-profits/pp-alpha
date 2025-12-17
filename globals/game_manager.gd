extends Node

var pause_menu: Control
var runtime_entities:Dictionary = {}
var player_data:Dictionary = {}

#state machine for ui opened
enum UIState {
	NONE,
	PAUSE_UI,
	INTER_UI
}
var current_ui_state:UIState = UIState.NONE

func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_from_storage()

# Called when the node enters the scene tree for the first time.
func set_pause_menu(menu: Control)->void:
	pause_menu = menu
	unpause()

func _unhandled_input(event : InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
		#Case where pausing is allowed
		if(pause_menu and current_ui_state != UIState.INTER_UI):
			get_tree().paused = !get_tree().paused
			pause_menu.visible = get_tree().paused
			if current_ui_state == UIState.NONE:
				current_ui_state = UIState.PAUSE_UI
			else:
				current_ui_state = UIState.NONE

func open_inter_ui()->void:
	current_ui_state = UIState.INTER_UI

func close_inter_ui()->void:
	current_ui_state = UIState.NONE

func unpause()->void:
	if (pause_menu):
		get_tree().paused = false
		pause_menu.hide()
		pause_menu.visible = false
		current_ui_state = UIState.NONE

func commit_to_storage()->void:
	var save_payload:Dictionary = {
		"player": player_data,
		"scenes": runtime_entities
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

func load_from_storage()->void:
	var save_file:FileAccess = null
	if not FileAccess.file_exists("user://savegame.save"):
		save_file = FileAccess.open("res://globals/default_state.txt", FileAccess.READ)
	else:
		save_file = FileAccess.open("user://savegame.save",FileAccess.READ)
	
	var json_text:String = save_file.get_as_text()
	save_file.close()
	
	var json:Variant = JSON.parse_string(json_text)
	if json == null:
		push_error("Failed to parse save file.")
		return
		
	runtime_entities = json["scenes"]
	player_data = json["player"]
	
	print("Game Loaded with : ",player_data,"\n", runtime_entities)
	
	
func save_scene_runtime_state(scene_name:String) -> void:
	print("before save: ",runtime_entities,"\n\n")
	var em:EntityManager = get_tree().current_scene.get_node("EntityManager")
	if em:
		runtime_entities[scene_name] = []
		for entity in em.get_children():
			if entity is Entity:
				runtime_entities[scene_name].append(entity.to_dict())
				print("saved: ",entity.to_dict())
	print("after save: ",runtime_entities,"\n\n")
	var player_node: Node = get_tree().current_scene.find_child("Player", true, false)
	if player_node:
		player_data = player_node.to_dict()
		print("player snapshot captured: ",player_data)
	

func load_scene_runtime_state()->void:
	var player_node: Node = get_tree().current_scene.find_child("Player", true, false)
	if player_node and player_data:
		player_node.from_dict(player_data)
	var scene_name:String = get_tree().current_scene.name
	var em:EntityManager = get_tree().current_scene.get_node("EntityManager")
	if em:
		for child in em.get_children():
			if child is Entity:
				child.queue_free()
	if em and runtime_entities.has(scene_name):
		for data:Dictionary in runtime_entities[scene_name]:
			em.load_from_dict(data)
			print("loaded: ", data)

func connect_scene_load_callback()->void:
	if not get_tree().is_connected("scene_changed", Callable(self, "load_scene_runtime_state")):
		get_tree().connect("scene_changed", Callable(self, "load_scene_runtime_state"), CONNECT_ONE_SHOT)

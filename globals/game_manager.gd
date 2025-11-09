extends Node

var pause_menu: Control
var runtime_entities:Dictionary = {}

func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called when the node enters the scene tree for the first time.
func set_pause_menu(menu: Control)->void:
	pause_menu = menu
	unpause()

func _unhandled_input(event : InputEvent)->void:
	if event.is_action_pressed("ui_cancel"):
#		Case where pausing is allowed
		if(pause_menu):
			get_tree().paused = !get_tree().paused
			pause_menu.visible = get_tree().paused

func unpause()->void:
	if (pause_menu):
		get_tree().paused = false
		pause_menu.hide()
		pause_menu.visible = false

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
	

func load_scene_runtime_state(scene_name:String)->void:
	var em:EntityManager = get_tree().current_scene.get_node("EntityManager")
	for child in em.get_children():
		child.queue_free()
	if em and runtime_entities.has(scene_name):
		for data:Dictionary in runtime_entities[scene_name]:
			em.load_from_dict(data)
			print("loaded: ", data)

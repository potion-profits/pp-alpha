extends Node2D
@onready var floor_map : Node2D = $FloorTilemap

func _ready()->void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))

func _on_move_town_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/casino/casino_menu.tscn")

func _on_move_storage_room_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		pass
		#get_tree().call_deferred("change_scene_to_file", INSERT_STORAGE_ROOM_SCENE)

func _on_npc_spawner_npc_spawned(npc_instance:Node2D) -> void:
	if floor_map.shelves.is_empty():
		return # no shelves in shop scene => no valid target for npcs
	setup_npc(npc_instance)
	add_child(npc_instance)
	npc_instance.move_to_point()

func setup_npc(npc : Node2D) -> void:
	npc.floor_map = floor_map
	npc.shelves = floor_map.shelves.duplicate()
	npc.target = npc.shelves.pop_at(randi_range(0, len(npc.shelves) - 1))
	npc.checkout = floor_map.checkout
	npc.global_position = floor_map.tilemap.map_to_local(floor_map.spawn)

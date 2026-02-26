extends Node2D

var spawn_location_pos : Array = []
@onready var spawn_locations: Node2D = $SpawnLocations
@onready var npcs: Node2D = $NPCs

const town_npc_scene : PackedScene = preload("res://scenes/npc_alt/town_npc.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	for location : Marker2D in spawn_locations.get_children():
		spawn_location_pos.append(location.position)
	spawn_town_npcs()

func spawn_npc(loc: Vector2) -> void:
	var t_npc : TownNpc = town_npc_scene.instantiate()
	t_npc.position = loc
	npcs.add_child(t_npc)

func spawn_town_npcs()->void:
	for location : Vector2 in spawn_location_pos:
		location = squib(location)
		spawn_npc(location)

func squib(loc : Vector2) -> Vector2:
	var off1 : int = randi_range(0,10)
	var off2 : int = randi_range(0,10)
	
	return loc + Vector2(off1, off2)

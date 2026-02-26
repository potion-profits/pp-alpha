extends Node2D

var spawn_location_pos : Array = []
## Expects a Node named SpawnLocations to be under the scene's root node that
## holds markers to spawn locations
@onready var spawn_locations: Node2D = $SpawnLocations
@onready var bb: Node2D = $BuildingsBoundaries
@onready var bot_bound: Marker2D = $ForegroundMarker
@onready var player: Player = $BuildingsBoundaries/Player
@onready var trees: TileMapLayer = $BuildingsBoundaries/TopBottomBoundaries/TreesForeground

const town_npc_scene : PackedScene = preload("res://scenes/npc_alt/roaming_npc.tscn")
var below : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pause_scene : Resource = preload("res://scenes/ui/pause_menu.tscn")
	var menu_instance : Node = pause_scene.instantiate()
	add_child(menu_instance)
	GameManager.set_pause_menu(menu_instance.get_node("PauseMenuControl"))
	for location : Marker2D in spawn_locations.get_children():
		spawn_location_pos.append(location.position)
	spawn_town_npcs()

func _process(_delta: float) -> void:
	if player.position.y > bot_bound.position.y and not below:
		below = true
		trees.modulate.a = 0.5
	
	if player.position.y < bot_bound.position.y and below:
		below = false
		trees.modulate.a = 1

func spawn_npc(loc: Vector2) -> void:
	var t_npc : RoamingNpc = town_npc_scene.instantiate()
	t_npc.position = loc
	bb.add_child(t_npc)
	bb.move_child(t_npc, 0)

func spawn_town_npcs()->void:
	for location : Vector2 in spawn_location_pos:
		location = squib(location)
		spawn_npc(location)

func squib(loc : Vector2) -> Vector2:
	var off1 : int = randi_range(-15,15)
	var off2 : int = randi_range(-15,15)
	
	return loc + Vector2(off1, off2)

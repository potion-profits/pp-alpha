extends Node2D

var spawn_location_pos : Array = []
## Expects a Node named SpawnLocations to be under the scene's root node that
## holds markers to spawn locations
@onready var spawn_locations: Node2D = $SpawnLocations
@onready var bb: Node2D = $BuildingsBoundaries
@onready var bot_bound: Marker2D = $ForegroundMarker
@onready var player: Player = $BuildingsBoundaries/Player
@onready var trees: TileMapLayer = $BuildingsBoundaries/TopBottomBoundaries/TreesForeground
@onready var credit_zone: Area2D = $BuildingsBoundaries/CreditZone

const town_npc_scene : PackedScene = preload("res://scenes/npc_alt/roaming_npc.tscn")
var below : bool = false
var in_credits : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func _input(event: InputEvent) -> void:
	if in_credits and event.is_action_pressed("interact") and GameManager.credits_flag:
		roll_credits()

func roll_credits()->void:
	get_tree().change_scene_to_file("res://scenes/credits/credits.tscn")

func spawn_npc(loc: Vector2) -> void:
	var t_npc : RoamingNpc = town_npc_scene.instantiate()
	t_npc.position = loc
	t_npc.z_index = 201
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


func _on_credit_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		in_credits = true


func _on_credit_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		in_credits = false

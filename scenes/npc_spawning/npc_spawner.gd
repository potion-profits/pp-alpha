extends Node

var npc : PackedScene = preload("res://scenes/npc_alt/basic_npc.tscn")
@onready var npc_respawn_timer : Timer = $NPCRespawnTimer
var time : float
signal npc_spawned

func _ready() -> void:
	time = randf_range(5.0, 15.0)
	npc_respawn_timer.start(time)

func _on_npc_respawn_timer_timeout() -> void:
	spawn_npc()

func spawn_npc()  -> void:
	var npc_instance : CharacterBody2D = npc.instantiate()
	npc_spawned.emit(npc_instance)
	time = randf_range(5.0, 15.0)
	npc_respawn_timer.start(time)

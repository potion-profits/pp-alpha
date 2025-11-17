extends Node

var npc : PackedScene = preload("res://scenes/npc_alt/basic_npc.tscn")
@onready var npc_respawn_timer : Timer = $NPCRespawnTimer
signal npc_spawned

func _on_npc_respawn_timer_timeout() -> void:
	spawn_npc()

func spawn_npc()  -> void:
	var npc_instance : CharacterBody2D = npc.instantiate()
	npc_spawned.emit(npc_instance)
	npc_respawn_timer.start()

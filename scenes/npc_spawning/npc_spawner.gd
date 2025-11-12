extends Node

var npc_path : = preload("res://scenes/npc_spawning/npc_path.tscn")
@onready var npc_respawn_timer : = $NPCRespawnTimer
signal npc_spawned

func _on_npc_respawn_timer_timeout() -> void:
	spawn_npc()

func spawn_npc()  -> void:
	var npc_instance : = npc_path.instantiate()
	npc_spawned.emit(npc_instance)
	npc_respawn_timer.start()

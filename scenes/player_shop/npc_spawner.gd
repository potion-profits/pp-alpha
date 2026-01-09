extends Node

## Reference to [Npc] scene
var npc : PackedScene = preload("res://scenes/npc_alt/basic_npc.tscn")
## Controls time before new NPC respawns
@onready var npc_respawn_timer : Timer = $NPCRespawnTimer
## Stores randf time to set [member npc_respawn_timer] to
var time : float
signal npc_spawned	## Sent to shop to handle NPC instance setup

const init_min = 7.0
const init_max = 15.0
const cont_min = 3.0
const cont_max = 8.0

func _ready() -> void:
	time = randf_range(init_min, init_max)
	npc_respawn_timer.start(time)

func _on_npc_respawn_timer_timeout() -> void:
	var npc_instance : CharacterBody2D = npc.instantiate()
	npc_spawned.emit(npc_instance)
	time = randf_range(cont_min, cont_max)
	npc_respawn_timer.start(time)

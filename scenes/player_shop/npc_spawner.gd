extends Node

## Reference to [Npc] scene
var npc_scene : PackedScene = preload("res://scenes/npc_alt/shop_npc.tscn")
## Controls time before new NPC respawns
@onready var npc_respawn_timer : Timer = $NPCRespawnTimer
## Stores randf time to set [member npc_respawn_timer] to
var rand_time : float
signal npc_spawned	## Sent to shop to handle NPC instance setup

var min_t : float
var max_t : float
var eight : int
var eleven : int
var fourteen : int

func _ready() -> void:
	eight = TimeManager.get_time_from_string('08:00')
	eleven = TimeManager.get_time_from_string('11:00')
	fourteen = TimeManager.get_time_from_string('14:00')
	var times : Array = get_respawn_range()
	rand_time = randf_range(times[0], times[1])
	npc_respawn_timer.start(rand_time)

func _on_npc_respawn_timer_timeout() -> void:
	var npc_instance : ShopNpc = npc_scene.instantiate()
	
	npc_spawned.emit(npc_instance)
	var times : Array = get_respawn_range()
	rand_time = randf_range(times[0], times[1])
	npc_respawn_timer.start(rand_time)
	
func get_respawn_range() -> Array:
	var t : Array = [0,0]
	if TimeManager.time <= eight:
		t[0] = 60
		t[1] = 80
	elif TimeManager.time <= eleven:
		t[0] = 10
		t[1] = 30
	elif TimeManager.time <= fourteen:
		t[0] = 7
		t[1] = 15
	else:
		t[0] = 7
		t[1] = 30
	return t

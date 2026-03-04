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

## Stores target in-game times for relevant real-world times to control variable spwan rate logic
@onready var target_times : Dictionary = {
	8: TimeManager.get_time_from_string('08:00'),
	11: TimeManager.get_time_from_string('11:00'),
	14: TimeManager.get_time_from_string('14:00'),
	17: TimeManager.get_time_from_string('17:00'),
}

func _ready() -> void:
	var times : Array = get_respawn_range()
	rand_time = randf_range(times[0], times[1])
	npc_respawn_timer.start(rand_time)

func _on_npc_respawn_timer_timeout() -> void:
	var npc_instance : ShopNpc = npc_scene.instantiate()
	
	npc_spawned.emit(npc_instance)
	var times : Array = get_respawn_range()
	rand_time = randf_range(times[0], times[1])
	npc_respawn_timer.start(rand_time)

## Uses in-game time to set spanwer respwan range for variable spawn rates
func get_respawn_range() -> Array:
	var t : Array = [0,0]
	if TimeManager.time <= target_times[8]:
		t[0] = 30
		t[1] = 35
	elif TimeManager.time <= target_times[11]:
		t[0] = 5
		t[1] = 10
	elif TimeManager.time <= target_times[14]:
		t[0] = 3
		t[1] = 5
	elif TimeManager.time <= target_times[17]:
		t[0] = 4
		t[1] = 10
	else:
		t[0] = 15
		t[1] = 30
	return t

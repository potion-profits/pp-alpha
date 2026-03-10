extends Node


## Handles non-entity and global sound effects (ex: user clicks, claudron ambience, all scene ambience, time specific sfx)

# Reference to each cauldron's ambience audio node
var cauldron_players: Array[AudioStreamPlayer2D] = []
var cauldron_muted: bool = false

#func _ready() -> void:
	#TimeManager.workday_end.connect()

# Only the first cauldon registered will play, the backroom seems small enough to not
# Distinguish that only one is playing
func register_cauld(cauld: AudioStreamPlayer2D) -> void:
	if !cauld or cauld in cauldron_players:
		return
	# For placement specific
	if cauldron_muted:
		return
	# If more than one cauldon exists in a scene, ignore those audio nodes
	if cauldron_players.size() > 0:
		cauld.stop()
		return
	cauldron_players.append(cauld)
	if !cauld.playing:
		cauld.play()

func unregister_cauld() -> void:
	if cauldron_players.size() > 0:
		cauldron_players[0].stop()
	else:
		return
	cauldron_players.clear()

# Certain scenes (such as grid placement) need all ambience muted
func mute_ambience() -> void:
	cauldron_muted = true
	for c in cauldron_players:
		if c.playing:
			c.stop()

func unmute_ambience() -> void:
	cauldron_muted = false

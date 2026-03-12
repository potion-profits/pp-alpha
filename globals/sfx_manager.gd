extends Node


## Handles non-entity and global sound effects (ex: user clicks, claudron ambience, all scene ambience, time specific sfx)

## References to SFX related sounds
@onready var alarm_sfx: AudioStreamPlayer = $AlarmSFX
@onready var click_sfx: AudioStreamPlayer = $ClickSFX
@onready var shelf_click_sfx: AudioStreamPlayer = $AlarmSFX
@onready var workday_end_sfx: AudioStreamPlayer = $WorkdayEndSFX
@onready var sfx_directory: Dictionary = {
	"alarm": alarm_sfx,
	"click": click_sfx,
	"shelf_click": shelf_click_sfx,
	"workday_end": workday_end_sfx
}

## References to dialouge related sounds
@onready var cat_dialouge: AudioStreamPlayer = $CatDialouge
@onready var npc_dialouge: AudioStreamPlayer = $NPCDialouge
@onready var shark_dialouge: AudioStreamPlayer = $SharkDialouge
@onready var dialouge_directory: Dictionary = {
	"cat": cat_dialouge,
	"shark": shark_dialouge,
	"npc": npc_dialouge
}

## References to ambient related sounds
@onready var casino_ambience: AudioStreamPlayer = $CasinoAmbience
@onready var town_ambience: AudioStreamPlayer = $TownAmbience
@onready var ambience_directory: Dictionary = {
	"casino": casino_ambience,
	"town": town_ambience
}


# Reference to each cauldron's ambience audio node
var cauldron_players: Array[AudioStreamPlayer2D] = []
var cauldron_muted: bool = false

func _ready() -> void:
	handle_signals()

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

func play_sfx(sound_name: String) -> void:
	var sound_to_play: AudioStreamPlayer = sfx_directory.get(sound_name)
	if sound_to_play:
		if !sound_to_play.playing:
			sound_to_play.play()
		else:
			sound_to_play.stop()

## Dialouge sound effects is simply a 40-50 second stream that plays 2-4 seconds
## proportional to text 
#func play_dialouge(dialouge_name: String, dialouge: String) -> void:
	## function that determines how long a sound should play (temp)
	#var how_long_to_play: int = 3
	

func handle_signals() -> void:
	TimeManager.workday_start.connect(play_sfx.bind("alarm"))
	TimeManager.workday_end.connect(play_sfx.bind("workday_end"))

extends Node


## Handles non-entity and global sound effects (ex: dialogue, transitions, time specific sfx)
## Tracks any polyphonic ambiences (like cauldrons)

## References to SFX related sounds
@onready var alarm_sfx: AudioStreamPlayer = $AlarmSFX
@onready var click_sfx: AudioStreamPlayer = $ClickSFX
@onready var shelf_click_sfx: AudioStreamPlayer = $AlarmSFX
@onready var workday_end_sfx: AudioStreamPlayer = $WorkdayEndSFX
@onready var transition_sfx: AudioStreamPlayer = $TransitionSFX
@onready var elevator_sfx: AudioStreamPlayer = $ElevatorSFX
@onready var sfx_directory: Dictionary = {
	"alarm": alarm_sfx,
	"click": click_sfx,
	"shelf_click": shelf_click_sfx,
	"workday_end": workday_end_sfx,
	"transition": transition_sfx,
	"elevator": elevator_sfx
}

## References to dialogue related sounds
@onready var cat_dialogue: AudioStreamPlayer = $CatDialogue
@onready var npc_dialogue: AudioStreamPlayer = $NPCDialogue
@onready var shark_dialogue: AudioStreamPlayer = $SharkDialogue
# Originally was going to map from speaker in JSON to sfx to be played
@onready var dialogue_directory: Dictionary = {
	"cat": cat_dialogue,
	"shark": shark_dialogue,
	"npc": npc_dialogue
}

# Reference to each cauldron's ambience audio node
var cauldron_players: Array[AudioStreamPlayer2D] = []
var cauldron_muted: bool = false

# Trackers for resume times for all dialogue
var dial_resume: float = 0.0

func _ready() -> void:
	handle_signals()

## Given the Ambience AudioStreamPlayer2D, ensures only one cauldron in a scenen plays ambience [br][br]
##
## Called when a cauldron is instatiated, tracks all cauldron references in cauldron_players
## and plays the first one in loaded in the scene (all others will be ignored)
## 
## Takes cauldron takes [param cauld] reference to AudioStreamPlayer2D
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

## When a cauldron is queue_free(), unregister the cauldron from the cauldron_players list
func unregister_cauld() -> void:
	if cauldron_players.size() > 0:
		cauldron_players[0].stop()
	else:
		return
	cauldron_players.clear()

## Certain scenes (such as grid placement) need all ambience muted
func mute_ambience() -> void:
	cauldron_muted = true
	for c in cauldron_players:
		if c.playing:
			c.stop()

## Unmmutes any cauldron ambience
func unmute_ambience() -> void:
	cauldron_muted = false

## Play sfx for the given sound [br][br]
##
## Checks the sfx_directory based on the string key passed in to determine 
## if there is a sound to play and plays it[br][br]
##
## Takes [param sound_name] as string key for sfx_directory [br]
func play_sfx(sound_name: String) -> void:
	var sound_to_play: AudioStreamPlayer = sfx_directory.get(sound_name)
	if !sound_to_play:
		return
	if !sound_to_play.playing:
		sound_to_play.play()
	else:
		sound_to_play.stop()

## Play dialouge for the given npc for ~1 second [br][br]
##
## Checks the dialogue_directory based on the string key passed in to determine 
## if there is a dialogue sound to play and plays it for 1 second[br][br]
##
## Takes [param sound_name] as string key for sfx_directory [br]
func play_dialogue(speaker: String) -> void:
	var dial_to_play: AudioStreamPlayer = dialogue_directory.get(speaker)
	var how_long_to_play: float = 1.1
	if !dial_to_play:
		return
	if !dial_to_play.playing:
		dial_to_play.play(dial_resume)
		# Timer for how long the song should play
		await get_tree().create_timer(how_long_to_play).timeout
		# track time to resume from and stop audio
		dial_resume = dial_to_play.get_playback_position()
		dial_to_play.stop()

func handle_signals() -> void:
	# alarm sounds plays when player "wakes up"
	TimeManager.workday_start.connect(play_sfx.bind("alarm"))
	# indicator that the work day has ended
	TimeManager.workday_end.connect(play_sfx.bind("workday_end"))

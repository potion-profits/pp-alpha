extends Node

## Background music for the main_shop, town_menu
@onready var shop_music: AudioStreamPlayer = $ShopMusic
## Background music for the first casino floor and casino games
@onready var casino_music: AudioStreamPlayer = $CasinoMusic
## Background music for the title screen
@onready var title_music: AudioStreamPlayer = $TitleMusic
## Music for the shop that plays after hours (once the shop closes)
@onready var after_shop_music: AudioStreamPlayer = $ShopAfterMusic
## Maps the level scene paths (called from SceneManager) to the song that should play for that scene
@onready var song_contexts: Dictionary = {
	"res://scenes/player_shop/main_shop.tscn": shop_music,
	"res://scenes/town/town.tscn": shop_music,
	"res://scenes/casino/casino_floor.tscn": casino_music,
	"res://scenes/casino/black_jack.tscn": casino_music,
	"res://scenes/ui/start_menu.tscn": title_music,
}
@onready var night_song_contexts: Dictionary = {
	"res://scenes/player_shop/main_shop.tscn": after_shop_music,
	"res://scenes/town/town.tscn": after_shop_music
}

@onready var night_target_time: int = TimeManager.get_time_from_string('17:00')

var is_night: bool = false

## A reference to the currently playing song
var current_song: AudioStreamPlayer
## A reference to the old song to transition from, needed for seemless transitions
var old_song: AudioStreamPlayer
## A reference to the tween used for crossfading
var crossfade: Tween
## Starting inaudible volume for fading in
var silent_db: float = -70.0
## Time for crossfade
var fade_time: float = 1.5
## Volume level for music
var full_volume_db: float = -20.0

func _ready() -> void:
	current_song = song_contexts.get("res://scenes/ui/start_menu.tscn")
	if current_song:
		current_song.play()
	# Signal that emits when end of workday and end of day occurs
	TimeManager.workday_end.connect(_switch_to_night_music)
	TimeManager.workday_start.connect(_switch_to_day_music)
	# Check if loading from save at night
	var loaded_time: String = TimeManager.get_string_from_time()
	if TimeManager.get_time_from_string(loaded_time) >= night_target_time:
		is_night = true

## Play background music for the given scene [br][br]
##
## Finds the relavent song to play for the given scene. Songs will change if the 
## given scene has a different song from the current song that needs to be switched to. [br][br]
##
## Takes [param scene_path] as file path to the scene [br]
func play_bg_music(scene_path: String) -> void:
	var next_scene_song: AudioStreamPlayer = null
	# first try night songs
	if !TimeManager.is_currently_daytime():
		next_scene_song = night_song_contexts.get(scene_path)
	# if no night version of the song exists or is daytime, fallback to song_contexts
	if !next_scene_song:
		next_scene_song = song_contexts.get(scene_path)
	# transition song if the next song is different
	if next_scene_song and current_song != next_scene_song:
		transition_song(next_scene_song)

## Connected to TimeManager workday_end signal that triggers after 5pm in-game [br][br]
##
## Some scenes play a different song once the workday ends. The current song will be switched
## and all songs will use the night version (if it exists), and the song will play on call
func _switch_to_night_music() -> void:
	var current_scene: String = SceneManager.current_scene().scene_file_path
	if current_scene:
		play_bg_music(current_scene)

## Connected to TimeManager workday_start signal that triggers after 3am in-game [br][br]
##
## This sets is_night to false, letting all day_default songs to play. The current song will be switched
## as the player may be moved to the main_shop when the signal is triggered 
func _switch_to_day_music() -> void:
	# Deffered for any scene swaps (ex: player pass out and goes back to main shop)
	play_bg_music("res://scenes/player_shop/main_shop.tscn")

## Crossfades from the current song to the new song [br][br]
## 
## Takes [param new_song] to switch to as [param AudioStreamPlayer] [br]
func transition_song(new_song: AudioStreamPlayer) -> void:
	if !current_song:
		current_song = new_song
		current_song.volume_db = full_volume_db
		current_song.play()
		return

	# kill any in-progress crossfade tweens
	if crossfade and crossfade.is_running():
		crossfade.kill()
	# prepare incoming song 
	new_song.volume_db = silent_db
	if !new_song.playing:
		new_song.play()
	# reassign respective songs
	old_song = current_song
	current_song = new_song

	crossfade = create_tween()
	# allows both the new and old song to fade concurrently
	crossfade.set_parallel(true)
	crossfade.tween_property(old_song, "volume_db", silent_db, fade_time)
	crossfade.tween_property(new_song, "volume_db", full_volume_db, fade_time)

	# tween signal once crossfade is finished
	crossfade.finished.connect(on_crossfade_finish)

## Resets audio states when crossfades finish
func on_crossfade_finish() -> void:
	if old_song:
		old_song.stop()
		old_song.volume_db = full_volume_db

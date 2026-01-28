extends Node

## Background music for the main_shop, town_menu
@onready var shop_music: AudioStreamPlayer = $ShopMusic
## Background music for the casino_floor, blackjack
@onready var casino_music: AudioStreamPlayer = $CasinoMusic
## Maps the level scene paths (called from SceneManager) to the song that should play for that scene
@onready var song_contexts: Dictionary = {
	"res://scenes/player_shop/main_shop.tscn": shop_music,
	"res://scenes/town_menu/town_menu.tscn": shop_music,
	"res://scenes/casino/casino_floor.tscn": casino_music,
	"res://scenes/casino/black_jack.tscn": casino_music,
	"res://scenes/ui/start_menu.tscn": shop_music
}

## A reference to the currently playing song
var current_song: AudioStreamPlayer
## A reference to the old song to transition from, needed for seemless transitions
var old_song: AudioStreamPlayer
## A reference to the tween used for crossfading
var crossfade: Tween
## Starting inaudible volume for fading in
var silent_db: float = -70.0
## Time for crossfade
var fade_time: float = 2.0

func _ready() -> void:
	current_song = song_contexts.get("res://scenes/ui/start_menu.tscn")
	if current_song:
		current_song.play()

## Play background music for the given scene [br][br]
##
## Finds the relavent song to play for the given scene. Songs will change if the 
## given scene has a different song from the current song that needs to be switched to. [br][br]
##
## Takes [param scene_path] as file path to the scene [br]
func play_bg_music(scene_path: String) -> void:
	var next_scene_song: AudioStreamPlayer = song_contexts.get(scene_path)
	if next_scene_song:
		if current_song != next_scene_song:
			transition_song(next_scene_song)

## Crossfades from the current song to the new song [br][br]
## 
## Takes [param new_song] to switch to as [param AudioStreamPlayer] [br]
func transition_song(new_song: AudioStreamPlayer) -> void:
	if !current_song:
		current_song = new_song
		current_song.volume_db = 0
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
	crossfade.tween_property(new_song, "volume_db", 0.0, fade_time)

	# tween signal once crossfade is finished
	crossfade.finished.connect(on_crossfade_finish)

## Resets audio states when crossfades finish
func on_crossfade_finish() -> void:
	if old_song:
		old_song.stop()
		old_song.volume_db = 0.0

extends Node

## Background music for the main_shop, town_menu
@onready var shop_music: AudioStreamPlayer = $ShopMusic
## Background music for the casino_floor, blackjack
@onready var casino_music: AudioStreamPlayer = $CasinoMusic
## Animation player used to interpolate and transition between songs
@onready var crossfade: AnimationPlayer = $Crossfade

## Maps the level scene paths (from SceneManager) to the song that should play for that scene
@onready var song_contexts: Dictionary = {
	"res://scenes/player_shop/main_shop.tscn": shop_music,
	"res://scenes/town_menu/town_menu.tscn": shop_music,
	"res://scenes/casino/casino_floor.tscn": casino_music,
	"res://scenes/casino/black_jack.tscn": casino_music
}

## Condition if music playing
var music_on: bool = true
## A reference to the currently playing song
var current_song: AudioStreamPlayer
#var tween: Tween = create_tween()

func _ready() -> void:
	current_song = shop_music
	current_song.play()

#func _process(_delta: float)->void:
	#update_music_status()
	#
#func update_music_status() -> void:
	#if current_song:
		#if music_on:
			#if !current_song.playing:
				#current_song.play()
		#else:
			#current_song.stop()

func play_bg_music(scene: String) -> void:
	var next_scene_song: AudioStreamPlayer = song_contexts.get(scene)
	if next_scene_song:
		# Check if scenes have changed, if so, transition if not don't transition
		if current_song != next_scene_song:
			transition_song(next_scene_song)

# takes in new song to transition to
# Uses tween interpolation to fade in/out with music
func transition_song(new_song: AudioStreamPlayer) -> void:
	if current_song.playing:
		current_song.stop()
		current_song = new_song
		current_song.play()
		
	#if current_song.playing and new_song.playing:
		#return
		#
		#var fade_out : Tween = create_tween()
		## fade out
		#fade_out.tween_property(current_song, "volume_db", linear_to_db(0.0), 2.0

		#current_song.stop()
		# fade in new song
		#current_song = new_song
	
	#tween cleanup
	

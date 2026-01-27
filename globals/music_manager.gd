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
## Flag that an audio stream is fading out
var fading_out: bool = false
## A reference to the currently playing song
var current_song: AudioStreamPlayer
## A reference to the song to transition to, needed for seemless transitions
var temp_song: AudioStreamPlayer
#var tween: Tween = create_tween()

func _ready() -> void:
	current_song = shop_music
	current_song.play()

func _process(delta: float)->void:
	if fading_out:
		temp_song.volume_db += 30*delta
		current_song.volume_db -= 30*delta
		# Once reached desired volume
		if temp_song.volume_db >= 0:
			current_song.volume_db = 0
			temp_song.volume_db = -70
			#Switch reference to new song and resume
			current_song = temp_song
			current_song.play(temp_song.get_playback_position())
			
			temp_song.stop()
			fading_out = false

func play_bg_music(scene: String) -> void:
	var next_scene_song: AudioStreamPlayer = song_contexts.get(scene)
	if next_scene_song:
		# Check if scenes have changed, if so, transition if not don't transition
		if current_song != next_scene_song:
			transition_song(next_scene_song)

# Takes in new song to transition to
# Uses tween interpolation to fade in/out with music
func transition_song(new_song: AudioStreamPlayer) -> void:
	# load in song to transition/fade to
	temp_song = new_song
	temp_song.volume_db = -70
	temp_song.play()
	#if current_song.playing:
		#current_song.stop()
		#current_song = new_song
		#current_song.play()
	fading_out = true
	#if current_song.playing and new_song.playing:
		#return
		#
		#var fade_out : Tween = create_tween()
		### fade out
		#fade_out.tween_property(current_song, "volume_db", linear_to_db(0.0), 2.0)

		#current_song.stop()
		# fade in new song
		#current_song = new_song
	
	#tween cleanup
	

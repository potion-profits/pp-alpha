extends Node2D

@onready var player = $Player
@onready var texture_progress_bar = $Player/TextureProgressBar

func _on_player_stamina_change(stamina : float):
	var percent = stamina / float(player.STAMINA)
	print("Stamina: ", stamina, "\tPercent: ", percent)
	texture_progress_bar.value = percent * 100
	

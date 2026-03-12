extends CanvasLayer

@onready var credit_container: VBoxContainer = $CreditContainer
@onready var game_over_text : Label = $GameOver
@export var scroll_speed :float = 200.0

var anim_done : bool = false
signal credit_ended


func _ready() -> void:
	if OS.is_debug_build():
		scroll_speed = 800
		anim_done = true

func _process(delta:float)->void:
	credit_container.position.y -= scroll_speed * delta
	game_over_text.position.y -= scroll_speed * delta
	
	if credit_container.position.y < -credit_container.size.y and anim_done:
		credit_ended.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_pixel":
		anim_done = true

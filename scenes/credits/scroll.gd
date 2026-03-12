extends CanvasLayer

@onready var credit_container: VBoxContainer = $CreditContainer
@export var scroll_speed :float = 100.0
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer

var anim_done : bool = false

func _ready() -> void:
	animation_player.play("fade_to_pixel")

func _process(delta:float)->void:
	credit_container.position.y -= scroll_speed * delta
	
	if credit_container.position.y < -credit_container.size.y and anim_done:
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_pixel":
		anim_done = true

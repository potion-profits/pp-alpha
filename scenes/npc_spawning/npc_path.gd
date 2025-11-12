extends Node2D

@onready var path_progress : = $NPCPath/PathProgress

const SPEED : float = 0.1

func _ready() -> void:
	path_progress.progress_ratio = 0

func _physics_process(delta : float) -> void:
	path_progress.progress_ratio += SPEED * delta
	if path_progress.progress_ratio >= 1:
		queue_free()

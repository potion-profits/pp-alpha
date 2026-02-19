extends Control

@onready var time: Label = $Time

func _process(_delta : float) -> void:
	time.text = TimeManager.get_string_from_time()

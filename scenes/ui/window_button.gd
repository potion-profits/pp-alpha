extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

# Available supported modes
const WINDOW_MODE_ARRAY: Array[String] = [
	"Fullscreen",
	"Windowed",
	"Borderless Windowed",
	"Borderless Fullscreen"
]

func _ready() -> void:
	add_window_mode_items()

func add_window_mode_items() -> void:
	for mode in WINDOW_MODE_ARRAY:
		option_button.add_item(mode)

func _on_option_button_item_selected(index: int) -> void:
	# Map option value index to WINDOW_MODE_ARRAY
	match index:
		0: #Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		4: #Borderless Fullscreen (This acts weird and I can't figure it out)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton
@onready var resolution_button: Control = $"../ResolutionButton"

# Available supported modes
const WINDOW_MODE_ARRAY: Array[String] = [
	"Windowed",
	"Fullscreen",
	"Borderless Windowed"
]

func _ready() -> void:
	add_window_mode_items()
	load_data()

func load_data() -> void:
	_on_option_button_item_selected(SettingDataContainer.window_mode_index)
	# Ensure selection index visual matches loaded index
	option_button.select(SettingDataContainer.window_mode_index)

func add_window_mode_items() -> void:
	for mode in WINDOW_MODE_ARRAY:
		option_button.add_item(mode)

func _on_option_button_item_selected(index: int) -> void:
	# Emit signal for save data
	SettingManager.emit_on_window_selected(index)
	# Emit signal for resolution button
	resolution_button.check_disable_resolution(index)
	# Map option value index to WINDOW_MODE_ARRAY
	match index:
		0: #Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: #Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: #Borderless Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)

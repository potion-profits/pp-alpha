extends Control

@onready var option_button:OptionButton = $HBoxContainer/OptionButton

# Default is resolution on project settings
const RESULTION_OPTIONS: Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1200": Vector2i(1920, 1200)
}

func _ready() -> void:
	add_resolution_items()

# TO SAVE: Signal to master controller that writes to config as a dict

func add_resolution_items() -> void:
	for res_text: String in RESULTION_OPTIONS:
		option_button.add_item(res_text)

func _on_option_button_item_selected(index: int) -> void:
	var resolution: Vector2i = RESULTION_OPTIONS.values()[index]
	if resolution:
		DisplayServer.window_set_size(resolution)

extends Control

@onready var option_button:OptionButton = $HBoxContainer/OptionButton

const window_fullscreen_idx = 1

# Default is resolution on project settings (1920 x 1080)
var RESOLUTION_OPTIONS: Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1280 x 720": Vector2i(1280, 720),
	"2560 x 1440": Vector2i(2560, 1440),
	"3840 x 2160": Vector2i(3840, 2160),
	"1920 x 1200": Vector2i(1920, 1200),
	"1680 x 1050": Vector2i(1680, 1050)
}

var current_screen: int
# the device's native resolution, ensure it's an option + for FullScreen
var native_res_text: String
var native_res: Vector2i
var native_res_idx: int

func _ready() -> void:
	current_screen = DisplayServer.window_get_current_screen()
	native_res = DisplayServer.screen_get_size(current_screen)
	native_res_text = "{x} x {y}".format({"x": native_res.x, "y": native_res.y})
	add_resolution_items()
	load_data()

func load_data() -> void:
	# Set loaded screen resolution
	_on_option_button_item_selected(SettingDataContainer.resolution_mode_index)
	# Ensure UI selection index visual matches loaded index
	option_button.select(SettingDataContainer.resolution_mode_index)
	# Check if disabled resolution options based on loaded window mode (1 is fullscreen)
	if (SettingDataContainer.window_mode_index == window_fullscreen_idx):
		handle_fullscreen_resolution()

func add_resolution_items() -> void:
	for res_text: String in RESOLUTION_OPTIONS:
		option_button.add_item(res_text)
	# if option for player's native resolution does not exist, add it as an option
	if RESOLUTION_OPTIONS.has(native_res_text):
		native_res_idx = RESOLUTION_OPTIONS.keys().find(native_res_text)
	else:
		option_button.add_item(native_res_text)
		native_res_idx = option_button.item_count - 1

func _on_option_button_item_selected(index: int) -> void:
	var resolution: Vector2i
	if index < RESOLUTION_OPTIONS.size():
		resolution = RESOLUTION_OPTIONS.values()[index]
	else:
		resolution = native_res
	SettingManager.emit_on_resolution_selected(index)
	DisplayServer.window_set_size(resolution)

## Signal emmited from the window_buttton scene
func on_window_switch(idx: int) -> void:
	if idx < 0:
		return
	# index window #1 is FullScreen mode
	if option_button:
		if idx == 1:
			handle_fullscreen_resolution()
			#var native_res : Vector2i = get_native_display_res(current_screen)
		# any other mode has the option button available
		else:
			option_button.disabled = false

## Handles FullScreen specific behavior 
##
## On Fullscreen selected, button is disabled
## and set as the screen native resolution 
func handle_fullscreen_resolution() -> void:
	if !option_button:
		return
	# Disable button
	option_button.disabled = true
	# Set to current native resolution
	option_button.select(native_res_idx)
	#SettingManager.emit_on_resolution_selected(native_res_idx)
	_on_option_button_item_selected(native_res_idx)

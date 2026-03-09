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
	# Ensure UI selection index visual matches loaded index
	option_button.select(SettingDataContainer.resolution_mode_index)
	# Check if disabled resolution options based on loaded window mode (1 is fullscreen)
	if (SettingDataContainer.window_mode_index == window_fullscreen_idx):
		handle_fullscreen_resolution()
	else:
		# Set loaded screen resolution
		apply_resolution_index(SettingDataContainer.resolution_mode_index)

## Adds resolution options (including the user's native res to the array (Which adds to the UI dropdown)
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
	apply_resolution_index(index)

func apply_resolution_index(index: int) -> void:
	var resolution: Vector2i
	if index < RESOLUTION_OPTIONS.size():
		resolution = RESOLUTION_OPTIONS.values()[index]
	else:
		resolution = native_res
	SettingManager.emit_on_resolution_selected(index)
	# Defer the actual resize to avoid race with window mode transitions
	call_deferred("_set_window_size", resolution)

func _set_window_size(resolution: Vector2i) -> void:
	DisplayServer.window_set_size(resolution)

## Signal emmited from the window_buttton scene
func on_window_switch(idx: int) -> void:
	if idx < 0:
		return
	# index window #1 is FullScreen mode
	if option_button:
		if idx == window_fullscreen_idx:
			handle_fullscreen_resolution()
		# any other mode has the option button available
		else:
			option_button.disabled = false
			# Defer so Godot finishes the window mode transition first
			_on_option_button_item_selected(option_button.selected)

## Handles FullScreen specific behavior 
##
## On Fullscreen selected, button is disabled
## and set as the selected screen as native resolution 
func handle_fullscreen_resolution() -> void:
	if !option_button:
		return
	# Disable button
	option_button.disabled = true
	# Set to current native resolution
	option_button.select(native_res_idx)

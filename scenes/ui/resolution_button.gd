extends Control

@onready var option_button:OptionButton = $HBoxContainer/OptionButton

# Default is resolution on project settings (1920 x 1080)
const RESULTION_OPTIONS: Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1280 x 720": Vector2i(1280, 720),
	"2560 x 1440": Vector2i(2560, 1440),
	"3840 x 2160": Vector2i(3840, 2160),
	"1920 x 1200": Vector2i(1920, 1200),
	"1680 x 1050": Vector2i(1680, 1050)
}

var current_screen: int
# the device's native resolution
var native_res_text: String
var native_res: Vector2i

func _ready() -> void:
	current_screen = DisplayServer.window_get_current_screen()
	native_res = DisplayServer.screen_get_size(current_screen)
	native_res_text = "{x} x {y}".format({"x": native_res.x, "y": native_res.y})
	add_resolution_items()
	load_data()

func load_data() -> void:
	_on_option_button_item_selected(SettingDataContainer.resolution_mode_index)
	# Ensure selection index visual matches loaded index
	option_button.select(SettingDataContainer.resolution_mode_index)
	# Disable resolution options based on loaded window mode
	check_disable_resolution(SettingDataContainer.window_mode_index)

func add_resolution_items() -> void:
	for res_text: String in RESULTION_OPTIONS:
		option_button.add_item(res_text)
	# if option for player's native resolution does not exist, add it as an option
	if !RESULTION_OPTIONS.get(native_res_text):
		option_button.add_item(native_res_text)

func _on_option_button_item_selected(index: int) -> void:
	var resolution: Vector2i = RESULTION_OPTIONS.values()[index]
	if resolution:
		SettingManager.emit_on_resultion_selected(index)
		DisplayServer.window_set_size(resolution)

func on_window_switch(idx: int) -> void:
	if idx == 1:
		check_disable_resolution(idx)
		#var native_res : Vector2i = get_native_display_res(current_screen)

func check_disable_resolution(idx: int) -> void:
	# 1 is fullscreen mode
	if !option_button:
		return
	if idx == 1:
		option_button.disabled = true
		SettingManager.emit_on_resultion_selected(4)
	else:
		option_button.disabled = false

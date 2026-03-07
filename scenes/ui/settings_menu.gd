extends CanvasLayer

@onready var settings_tab: TabContainer = $MarginContainer/VBoxContainer/SettingsTab/TabContainer
var origin_scene: String

func open(origin: String) -> void:
	origin_scene = origin
	if origin_scene == "pause_menu":
		GameManager.pause_menu.hide()
	# on open, set to the default tab (Gameplay tab is 0)
	settings_tab.current_tab = 0
	self.layer = 10
	show()
	# Block ui_cancel from reaching GameManager while settings is open
	set_process_unhandled_input(true)

func close() -> void:
	self.layer = -1
	hide()
	set_process_unhandled_input(false)

func _on_exit_pressed() -> void:
	# Save settings on exit and close menu
	SettingManager.emit_set_settings_dict(SettingDataContainer.create_storage_dict())
	close()
	
	# depending on where the settings menu was opened (pause menu or start menu) behaves differently
	if origin_scene == "start_menu":
		SceneManager.change_to("res://scenes/ui/start_menu.tscn")
	elif origin_scene == "pause_menu":
		GameManager.pause_menu.show()

extends Control

func open() -> void:
	show()

func close() -> void:
	hide()

func _on_exit_pressed() -> void:
	# Save settings on exit
	SettingManager.emit_set_settings_dict(SettingDataContainer.create_storage_dict())
	close()
	SceneManager.change_to("res://scenes/ui/start_menu.tscn")

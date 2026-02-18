# DialogueManager.gd (autoload)
extends Node

var dialogue_data: Dictionary = {}

signal dialogue_shown(text: String, speaker: String)

func _ready() -> void:
	load_all_dialogues()

## Loads all JSON files from the dialogues folder into dialogue_data keyed by filename
func load_all_dialogues() -> void:
	var path: String = "res://assets/dialogue/dialogues/"
	var dir: DirAccess = DirAccess.open(path)
	if not dir:
		print(">>> ERROR: Could not open dialogues directory")
		return
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var key: String = file_name.get_basename()
			var file: FileAccess = FileAccess.open(path + file_name, FileAccess.READ)
			if file:
				var parsed: Variant = JSON.parse_string(file.get_as_text())
				if parsed is Dictionary:
					dialogue_data[key] = parsed
					print(">>> Loaded dialogue file: ", key)
		file_name = dir.get_next()
	dir.list_dir_end()

## Returns a full dialogue set by file key (e.g. "tutorial", "npcs", "cutscenes")
func get_data(key: String) -> Dictionary:
	return dialogue_data.get(key, {})

## Returns a specific array from a dialogue file (e.g. get_array("tutorial", "tutorial") for tutorial steps)
func get_array(file_key: String, array_key: String) -> Array:
	var data: Dictionary = get_data(file_key)
	return data.get(array_key, [])

## Returns a specific dialogue entry by file key and dialogue id
func get_dialogue(file_key: String, dialogue_id: String) -> Dictionary:
	var data: Dictionary = get_data(file_key)
	var dialogues: Dictionary = data.get("dialogues", {})
	return dialogues.get(dialogue_id, {})

## Shows a dialogue by file key and dialogue id, emits signal
func show_dialogue(file_key: String, dialogue_id: String) -> Dictionary:
	var dialogue: Dictionary = get_dialogue(file_key, dialogue_id)
	if dialogue:
		var speaker: String = dialogue.get("speaker", "")
		var text: String = dialogue.get("text", "")
		dialogue_shown.emit(text, speaker)
	return dialogue

## Convenience for emitting dialogue text directly
func show_text(text: String, speaker: String = "") -> void:
	dialogue_shown.emit(text, speaker)

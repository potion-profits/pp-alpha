extends Control

## Handles switching buttons to appropriate alternate sprite depending on state
##
## Based on the LanguageManager offset and the state offset
##
## @deprecated: Currently used but will be reduced in functionality when multi-language support becomes unsupported


func _ready()->void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Scene transition entity for the casino exterior.
## On interact, transitions the player to the casino floor scene.
extends Entity

@onready var interactable: Area2D = $Interactable

var interact_key: String = InputMap.get_action_description("interact").split(" ")[0]
var DOOR_TOOLTIP: String = "Press %s to Enter" %[interact_key]
var block_flag : bool = false
signal block_dial

func _ready() -> void:
	interactable.interact = _on_interact
	interactable.tooltip = DOOR_TOOLTIP
	
	super._ready()
	entity_code = "casino_ext"

## Transitions to the casino floor scene on interaction.
func _on_interact() -> void:
	if block_flag:
		block_dial.emit()
	else:
		SceneManager.change_to("res://scenes/casino/casino_floor.tscn")

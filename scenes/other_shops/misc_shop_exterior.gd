## Scene transition entity for the misc shop exterior.
## On interact, transitions the player to the town menu scene.
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
	entity_code = "misc_shop_ext"

## Transitions to the town menu scene on interaction.
func _on_interact() -> void:
	if block_flag:
		block_dial.emit()
	else:
		SceneManager.change_to("res://scenes/supply_shop/supply_shop.tscn")

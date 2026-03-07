## Scene transition entity for the player shop exterior.
## On interact, transitions the player to the main shop scene.
extends Entity

@onready var interactable: Area2D = $Interactable

var interact_key: String = InputMap.get_action_description("interact").split(" ")[0]
var DOOR_TOOLTIP: String = "Press %s to Enter" %[interact_key]

func _ready() -> void:
	interactable.interact = _on_interact
	interactable.tooltip = DOOR_TOOLTIP
	
	super._ready()
	entity_code = "player_shop_ext"

## Transitions to the main shop scene on interaction.
func _on_interact() -> void:
	SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")

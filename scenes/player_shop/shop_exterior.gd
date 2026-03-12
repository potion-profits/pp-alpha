## Scene transition entity for the player shop exterior.
## On interact, transitions the player to the main shop scene.
extends Entity

@onready var interactable: Area2D = $Interactable

var player_in_area: Player
var DOOR_TOOLTIP: String = "Press %s to Enter"

func _ready() -> void:
	interactable.interact = _on_interact
	interactable.set_tooltip_label(DOOR_TOOLTIP)
	
	super._ready()
	entity_code = "player_shop_ext"

## Transitions to the main shop scene on interaction.
func _on_interact() -> void:
	SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")


func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_area = body
		set_process(true)


func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_area = null
		set_process(false)

func _process(_delta: float) -> void:
	if player_in_area:
		interactable.set_tooltip_label(DOOR_TOOLTIP)

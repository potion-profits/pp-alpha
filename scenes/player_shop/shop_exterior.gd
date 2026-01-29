extends Entity	#will help store placement and inventory information for persistence

## Crates are interactable entities that dispense empty bottles.[br][br]
## 
## On interact, if the player has an empty slot, gives the player an empty bottle.
## Once the crate has run out of bottles, changes the sprite to visually represent this.

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable	## Reference to interactable component

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "player_shop_ext"

#Handles player interaction with crate when appropriate
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	#makes sure interaction is from a player
	if player:
		SceneManager.change_to("res://scenes/player_shop/main_shop.tscn")

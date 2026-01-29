extends Entity	#will help store placement and inventory information for persistence

## Crates are interactable entities that dispense empty bottles.[br][br]
## 
## On interact, if the player has an empty slot, gives the player an empty bottle.
## Once the crate has run out of bottles, changes the sprite to visually represent this.

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable	## Reference to interactable component
@onready var full_crate: Sprite2D = $full_crate	## Sprite reference
@onready var empty_crate: Sprite2D = $empty_crate	## Sprite reference
@onready var select_sprite: AnimatedSprite2D = $SelectionAnimation	## Sprite Reference
@onready var capacity_popup: Sprite2D = $capacity_popup	## Sprite reference
@export var animation_name: String = "default"	## Name of animation to play

# default vars
const MAX_AMT: int = 8	## Max amount crates can hold
var crate_inv_amt : int = 8	## Current amount this crate has

func _ready()-> void:
	#links interactable template to cauldron specific method (needed for all interactables)
	interactable.interact = _on_interact
	#sets up entity info 
	super._ready()
	#used to find out what actual scene to place in entity manager
	entity_code = "crate"
	if !inv:
		inv = Inv.new(1)
	
	var bottle: InvItem = ItemRegistry.new_item("item_empty_bottle")
	inv.slots[0].item = bottle
	inv.slots[0].amount = crate_inv_amt # initial amt for crate
	update_crate()
	
	# This allows the sprite region to be modified and updated
	capacity_popup.region_enabled = true
	update_popup()
	

#Handles player interaction with crate when appropriate
func _on_interact()->void:
	var player:Player = get_tree().get_first_node_in_group("player")
	#makes sure interaction is from a player
	if player:
		if inv.slots[0].item and inv.slots[0].amount > 0:	#something is in the crate waiting to be picked up
			var temp_item : InvItem = inv.slots[0].item._duplicate()
			if player.collect(temp_item):
				inv.slots[0].amount-=1	#the player collected, so remove item from crate
				if inv.slots[0].amount <= 0:
					inv.slots[0].item = null # make item null if no more items to be picked up
					update_crate()
	update_popup()

## Updates this crate's sprite to reflect emptiness
func update_crate()->void:
	if inv.slots[0].item and inv.slots[0].amount > 0:
		full_crate.visible = true
		empty_crate.visible = false
	else:
		full_crate.visible = false
		empty_crate.visible = true

## Creates and returns a dictionary representation of this crate. See also [method from_dict].
func to_dict()-> Dictionary:
	var crate_state:Dictionary = {
		"bottles": inv.slots[0].amount
	}
	crate_state.merge(super.to_dict())
	return crate_state

## Reconstructs a crate with the given data.[br][br]
##
## Expects [param data] to have [code]"bottles": int[/code] as a key/value pair. See also [method to_dict].
func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	if data.has("bottles") and data["bottles"] >= 0:
		crate_inv_amt = data["bottles"]

## Toggles on the selection indication sprite. See also [method un_highlight].
func highlight()->void:
	if select_sprite && select_sprite.sprite_frames.has_animation(animation_name):
		select_sprite.visible = true
		select_sprite.play(animation_name)

## Toggles off the selection indication sprite. See also [method highlight].
func un_highlight()->void:
	if select_sprite:
		select_sprite.visible = false
		select_sprite.stop()

## Changes crate attributes to simulate a refilled crate.[br][br]
##
## Sets the item to a bottle, sets the amount to refilled amount, and updates the sprite.[br][br]
##
## Takes [param _type] to ensure compatabiltity with refill script but is unused.
func refill(_type: String)->void:
	var bottle: InvItem = ItemRegistry.new_item("item_empty_bottle")
	inv.slots[0].item = bottle
	inv.slots[0].amount = MAX_AMT
	update_crate()

## Calculates and updates the crate's current capacity popup
func update_popup()->void:
	var new_x : int = 16 * (inv.slots[0].amount)
	
	var new_region : Rect2 = Rect2(
		new_x,
		0,
		16,
		16
	)
	
	capacity_popup.region_rect = new_region
	
	
## Popup only when the player is within the crate's interactable body
## NOTE: This only considers the player's hitbox, not it's interacting
##		 component.
func _on_interactable_body_entered(body: Node2D) -> void:
	if body is Player:
		capacity_popup.show()
		update_popup()

func _on_interactable_body_exited(body: Node2D) -> void:
	if body is Player:
		capacity_popup.hide()
		update_popup()

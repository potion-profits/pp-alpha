extends Entity	#will help store placement and inventory information for persistence

#interactable entities will need an interactble scene as a child node 
@onready var interactable: Area2D = $Interactable
@onready var full_crate: Sprite2D = $full_crate
@onready var empty_crate: Sprite2D = $empty_crate

# default vars
var crate_inv_amt : int = 64

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

#Handles player interaction with cauldron when appropriate
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

func update_crate()->void:
	if inv.slots[0].item and inv.slots[0].amount > 0:
		full_crate.visible = true
		empty_crate.visible = false
	else:
		full_crate.visible = false
		empty_crate.visible = true

	
func _process(_delta: float) -> void:
	pass
#
func to_dict()-> Dictionary:
	var crate_state:Dictionary = {
		"bottles": inv.slots[0].amount
	}
	crate_state.merge(super.to_dict())
	return crate_state

func from_dict(data:Dictionary)->void:
	super.from_dict(data)
	if data.has("bottles") and data["bottles"] >= 0:
		crate_inv_amt = data["bottles"]

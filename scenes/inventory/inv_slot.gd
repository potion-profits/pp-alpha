extends Resource

class_name InvSlot

## Represents an inventory slot and handles storing this slot's information.
##
## Inventory slots are intermediates between the [Inv] and an [InvItem].

@export var item: InvItem ## References the item that is held within this slot.
@export var amount: int ## The amount of [member item] that this slot holds.
var owner: Inv = null ## Holds the inventory that this slot is a part of.
var index: int = -1 ## The index that this slot is positioned at in the owner inventory.

## Creates and returns a dictionary representation of this inventory slot. 
## 
## Because slots necessarily need to be under an inventory, 
## there is no need to store that information here to save the state. Only the 
## item and the amount is stored.  
func to_dict()->Dictionary:
	var item_d :Dictionary = item.to_dict() if item else {}
	return{
		"item":item_d,
		"amount":amount
	}

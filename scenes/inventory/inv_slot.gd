extends Resource

class_name InvSlot

#represents an inventory slot

@export var item: InvItem
@export var amount: int 
var owner: Inv = null
var index: int = -1

func to_dict()->Dictionary:
	var item_d :Dictionary = item.to_dict() if item else {}
	return{
		"item":item_d,
		"amount":amount
	}

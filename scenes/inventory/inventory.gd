extends Resource

class_name Inv

signal update

#holds all the slots in inventory through inspector. 
#sprites currently holds 5 statically, could do dynamic but not currently
@export var slots: Array [InvSlot]
var db_id: int

#goes through slots and inserts in correct slot, next empty slot, or returns false
func insert(item: InvItem) -> bool:
	var itemSlots : Array [InvSlot] = slots.filter(func(slot: InvSlot) -> bool:return slot.item == item)
	if !itemSlots.is_empty():
		itemSlots[0].amount += 1
	else:
		var emptySlots: Array [InvSlot]= slots.filter(func(slot:InvSlot)-> bool: return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount +=1
		else:
			return false
	update.emit()	#this sends signal to update sprites
	return true

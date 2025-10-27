extends Resource

class_name Inv

signal update

@export var slots: Array [InvSlot]

func insert(item: InvItem) -> void:
	var itemSlots : Array [InvSlot] = slots.filter(func(slot: InvSlot) -> bool:return slot.item == item)
	if !itemSlots.is_empty():
		itemSlots[0].amount += 1
	else:
		var emptySlots: Array [InvSlot]= slots.filter(func(slot:InvSlot)-> bool: return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount +=1
	update.emit()

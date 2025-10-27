extends Resource

class_name Inv

signal update

@export var items: Array [InvItem]

func insert(item: InvItem) -> void:
	var itemSlots : Array [InvItem] = items.filter(func(slot: InvItem) -> bool:return slot.item == item)
	if !itemSlots.is_empty():
		itemSlots[0].amount += 1
	else:
		var emptySlots: = items.filter(func(slot:InvItem)-> bool: return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount +=1
	update.emit()

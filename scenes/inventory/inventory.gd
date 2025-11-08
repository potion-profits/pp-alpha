extends Resource
class_name Inv

signal update
signal selection_changed(selected_index:int)

#holds all the slots in inventory through inspector. 
#sprites currently holds 5 statically, could do dynamic but not currently
@export var slots: Array [InvSlot]
var selected_index:int = -1
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

func remove_selected(amount: int = 1)->bool:
	var slot:InvSlot = get_selected_slot()
	if slot and slot.amount >= amount:
		slot.amount -= amount
		if slot.amount <= 0:
			slot.item = null
		update.emit()
		return true
	return false

func get_selected_slot()->InvSlot:
	if selected_index >= 0 and selected_index<slots.size():
		return slots[selected_index]
	return null

func select_slot(index:int)->void:
	if index>=0 and index<slots.size():
		selected_index = index
		update.emit()
		selection_changed.emit(selected_index)

func deselect()->void:
	selected_index = -1
	update.emit()
	selection_changed.emit(selected_index)

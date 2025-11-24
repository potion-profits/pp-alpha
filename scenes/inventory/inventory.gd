extends Resource
class_name Inv

signal update
signal selection_changed(selected_index:int)

#holds all the slots in inventory through inspector. 
#sprites currently holds 5 statically, could do dynamic but not currently
@export var slots: Array [InvSlot]
var selected_index:int = -1

func _init(size:int = 5) -> void:
	for i in range(size):
		slots.push_back(InvSlot.new())
		slots[i].owner = self
		slots[i].index = i

#goes through slots and inserts in correct slot, next empty slot, or returns false
func insert(item: InvItem) -> bool:
	var itemSlots : Array [InvSlot] = slots.filter(func(slot: InvSlot) -> bool:return item.equals(slot.item) and slot.amount < item.max_stack_size)
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

func insert_on_cursor(idx: int, invSlot: InvSlot)->void:
	var old_owner: Inv = invSlot.owner
	var old_idx: int = invSlot.index
	 
	if old_owner and old_owner.slots[old_idx] == invSlot:
		var empty_slot: InvSlot = InvSlot.new()
		empty_slot.owner = old_owner
		empty_slot.index = old_idx
		old_owner.slots[old_idx] = empty_slot
		old_owner.update.emit()
		
	invSlot.owner = self
	invSlot.index = idx
	slots[idx] = invSlot
	update.emit()
	
func to_dict()->Dictionary:
	var slot_data:Array = []
	for slot in slots:
		slot_data.append(slot.to_dict())
	return{
		"slots":slot_data,
		"selected_index":selected_index
	}

func from_dict(data: Dictionary)->void:
	slots.clear()
	var idx:int = 0
	for slot_info:Dictionary in data["slots"]:
		var slot:InvSlot = InvSlot.new()
		slot.owner = self
		slot.amount = slot_info["amount"]
		slot.index = idx
		if slot_info["item"]:
			slot.item = InvItem.new()
			slot.item.from_dict(slot_info["item"])
		slots.append(slot)
		idx+=1
	selected_index = data["selected_index"]
	update.emit()

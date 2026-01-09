extends Resource
class_name Inv

## Manages inventory representation and manipulation.
##
## Contains functionality for manipulation, saving/loading, 
## and slot based management.

## Singals when the inventory has been manipulated, indicated a visual update is required.
signal update	
signal selection_changed(selected_index:int)	## Signals that a new slot was selected

## Holds the [InvSlot] for each of the spots in the inventory
@export var slots: Array [InvSlot]	
## Index corresponding the the slot that is currently selected in this inventory
var selected_index:int = -1	
## Lock to maintain gameplay clarity in inventories with different manipulations happening at once
var lock: bool = false	

# called when new is used
func _init(size:int = 5) -> void:
	for i in range(size):
		slots.push_back(InvSlot.new())
		slots[i].owner = self
		slots[i].index = i

#goes through slots and inserts in correct slot, next empty slot, or returns false
## Handles an attempted insert of the given item into the inventory. 
## Returns true on success, otherwise false. [br][br]
## 
## Insertion is only possible when there is an empty slot in the inventory or 
## there is already a matching item slot under the max stack size. [br][br]
## 
## Takes [param item] as an [InvItem] to be inserted if possible. 
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

## Removes the item in the slot indicated by [member selected_index]. Returns true on success.[br][br]
## 
## Properly checks that the slot is valid and updates accordingly.
## 
## Takes [param amount] to subtract from the slot, given its a valid slot.
func remove_selected(amount: int = 1)->bool:
	var slot:InvSlot = get_selected_slot()
	if slot and slot.amount >= amount:
		slot.amount -= amount
		if slot.amount <= 0:
			slot.item = null
		update.emit()
		return true
	return false

## Returns the slot that is selected using [member selected_index]. 
## Returns null if the index is invalid.
func get_selected_slot()->InvSlot:
	if selected_index >= 0 and selected_index<slots.size():
		return slots[selected_index]
	return null

## Changes [member selected_index] to the given index 
## and emits appropriate signals. See [signal selection_changed].
func select_slot(index:int)->void:
	if index>=0 and index<slots.size():
		selected_index = index
		update.emit()
		selection_changed.emit(selected_index)

## Changes [member selected_index] to an invalid slot, effectively selecting none.
## Also emits signals to represent that no slot is selected. 
## See [signal selection_changed].
## @deprecated: Currently, only player can select and is not allowed to deselect.
func deselect()->void:
	selected_index = -1
	update.emit()
	selection_changed.emit(selected_index)

## Handles transferring of item information and ownership between slots. [br][br]
##
## Used specifically when moving items with the mouse. 
## Ensures that if an item is clicked but not dropped, 
## it will remain in the correct slot even when exiting the scene.
func insert_on_cursor(idx: int, invSlot: InvSlot)->void:
	var old_owner: Inv = invSlot.owner
	var old_idx: int = invSlot.index
	
	# when inserting item from a different owner
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
	
## Creates and returns a dictionary representation of this inventory. [br][br]
##
## The dictionary holds the selected index 
## and calls [method InvSlot.to_dict] on each of this inventory's slots. [br][br]
##
## See also [method from_dict].
func to_dict()->Dictionary:
	var slot_data:Array = []
	for slot in slots:
		slot_data.append(slot.to_dict() if slot else {})
	return{
		"slots":slot_data,
		"selected_index":selected_index
	}

## Reconstructs an inventory with the given data.[br][br]
##
## Expects [param data] to have  [code]"slots": Dictionary[/code]  and  
##  [code]"selected_index": int[/code]  as key/value pairs. 
## See also [method to_dict].
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

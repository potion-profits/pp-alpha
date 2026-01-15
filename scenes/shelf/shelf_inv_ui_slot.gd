extends Button

## Handles the behavior and representation of an individual slot in the shelf
## UI.

## Reference to container the will hold the item visual
@onready var container: CenterContainer = $ShelfCenterContainer

## Holds the visual representation of the item
var item_stack: ItemStackUI
## The index that this slot represents within the shelf UI array
var index: int
## The inventory that this slot is a part of 
var inv: Inv

## Inserts the given item stack ([param i_stack]) to this slot
func insert(i_stack: ItemStackUI) -> void:
	item_stack = i_stack
	container.add_child(item_stack)
	
	if !item_stack.invSlot or inv.slots[index] == item_stack.invSlot:
		return
	#item_stack.update_slot()
	inv.insert_slot_at(index, i_stack.invSlot)

## Removes the item from this slot and returns it.
func pick_item()->ItemStackUI:
	var item:ItemStackUI = item_stack
	if item_stack and item_stack.invSlot and item_stack.invSlot.item:
		container.remove_child(item)
		item_stack = null
	return item

## Returns true if there is no item in this slot
func is_empty()->bool:
	if item_stack:
		return !item_stack.invSlot.item
	return true

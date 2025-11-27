extends Button

@onready var container: CenterContainer = $CenterContainer

var item_stack: ItemStackUI
var index: int
var inv: Inv

func insert(i_stack: ItemStackUI) -> void:
	item_stack = i_stack
	container.add_child(item_stack)
	
	if !item_stack.invSlot or inv.slots[index] == item_stack.invSlot:
		return
	#item_stack.update_slot()
	inv.insert_on_cursor(index, i_stack.invSlot)

func pick_item(amount: int = -1)->ItemStackUI:
	if not item_stack or not item_stack.invSlot or not item_stack.invSlot.item:
		return null
	
	var stack_ui: ItemStackUI = item_stack
	var slot: InvSlot = stack_ui.invSlot
	
	if amount == -1 or amount >= slot.amount:
		container.remove_child(stack_ui)
		item_stack = null
		return stack_ui
	
	slot.amount -= amount
	
	var picked_ui : ItemStackUI = stack_ui.duplicate()
	picked_ui.invSlot = slot.duplicate()
	picked_ui.invSlot.amount = amount
	
	return picked_ui
	

func is_empty()->bool:
	if item_stack:
		return !item_stack.invSlot.item
	return true

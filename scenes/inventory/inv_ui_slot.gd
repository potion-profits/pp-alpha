extends Button

@onready var container: CenterContainer = $CenterContainer
@onready var select_border: NinePatchRect = $select_border

#keeps track if its currently selected, should only ever be 1 slot
var selected:bool = false;
var item_stack: ItemStackUI
var index: int
var inv: Inv

func _ready() -> void:
	select_border.visible = false

func insert(i_stack: ItemStackUI) -> void:
	item_stack = i_stack
	container.add_child(item_stack)
	
	if !item_stack.invSlot or inv.slots[index] == item_stack.invSlot:
		return
	inv.insert_on_cursor(index, i_stack.invSlot)
	inv.update.emit()

#increases the size of the texture in the slot
func select() -> void:
	selected = true
	select_border.visible = true

func deselect()->void:
	selected = false
	select_border.visible = false

func pick_item()->ItemStackUI:
	var item:ItemStackUI = item_stack
	if item_stack and item_stack.invSlot and item_stack.invSlot.item:
		container.remove_child(item)
		item_stack = null
	
	return item

func is_empty()->bool:
	if item_stack:
		return !item_stack.invSlot.item
	return true

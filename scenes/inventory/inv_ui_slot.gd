extends Button

## Handles the visual representation of an individual slot in the player's inventory.

## Reference to the centered container that will hold the item visual
@onready var container: CenterContainer = $CenterContainer
## Reference to the selection indicator
@onready var select_border: NinePatchRect = $select_border
## Reference to the slot background
@onready var slot_bg: Sprite2D = $slot_background

var selected:bool = false	## Set to true when this slot is the selected slot
var item_stack: ItemStackUI ## Holds the visual item stack for this slot
var index: int	## Keeps the index of this slot to maintain order
var inv: Inv	## Holds the inventory that this slot is a part of 

# starts with a hidden select border
func _ready() -> void:
	select_border.self_modulate.a = 0.8
	select_border.visible = false

## Inserts the given item stack into this slot
func insert(i_stack: ItemStackUI) -> void:
	item_stack = i_stack
	container.add_child(item_stack)
	
	if !item_stack.invSlot or inv.slots[index] == item_stack.invSlot:
		return
	inv.insert_slot_at(index, i_stack.invSlot)
	inv.update.emit()

## Signifies this slot is selected by turning on the selected border
func select() -> void:
	selected = true
	select_border.visible = true

## Signifies deselecting this slot by turning off the selected border
func deselect()->void:
	selected = false
	select_border.visible = false

## Removes the held item_stack from this slot visually and returns the stack
func pick_item()->ItemStackUI:
	var item:ItemStackUI = item_stack
	if item_stack and item_stack.invSlot and item_stack.invSlot.item:
		container.remove_child(item)
		item_stack = null
	
	return item

## Returns true if the there is no item in this slot, otherwise false.
func is_empty()->bool:
	if item_stack:
		return !item_stack.invSlot.item
	return true

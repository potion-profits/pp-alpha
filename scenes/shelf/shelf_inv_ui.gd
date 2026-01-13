extends Control

## Controls the visual representation of the shelf/player inventory UI.
##
## Includes functionality to merge player and shelf inventory information and
## display properly.

## Reference to the players slots as buttons
@onready var player_slots: Array = $NinePatchRect2/ShelfPlayerContainer.get_children()
## Reference to the shelf slots as buttons
@onready var shelf_slots: Array = $NinePatchRect/ShelfContainer.get_children()
## Reference to the ItemStackUI that visually represents an item
@onready var ItemStackUIClass : PackedScene = preload("res://scenes/inventory/inv_item_stack_ui.tscn")

var player_slot_count: int = 5	## The amount of slots the player owns
var shelf_slot_count: int = 12	## The amount of slots the shelf owns

## Holds the combination of player slots and shelf slots
var slots: Array = player_slots + shelf_slots

## Holds the players inventory after using [method set_inventories]
var player_inv: Inv
## Holds the shelf's inventory after using [method set_inventories]
var shelf_inv: Inv

## Flag toggled on when the UI is being shown
var is_open : bool = false

## Holds an ItemStackUI object that maintains the item to be moved.
var item_on_cursor: ItemStackUI

#dynamically sets inv which is set wherever a inventory is to be made
## Stores and correctly connects the given 
## [param _player_inv] and [param _shelf_inv] to [member player_inv] and
## [member shelf_inv].
func set_inventories(_player_inv: Inv, _shelf_inv: Inv) -> void:
	# if signal connected, disconnect
	if player_inv and player_inv.update.is_connected(update_slots):
		player_inv.update.disconnect(update_slots)
	if shelf_inv and shelf_inv.update.is_connected(update_slots):
		shelf_inv.update.disconnect(update_slots)

	player_inv = _player_inv
	shelf_inv = _shelf_inv
	
	# Connect new signals
	if player_inv:
		player_inv.update.connect(update_slots)
	if shelf_inv:
		shelf_inv.update.connect(update_slots)
	if player_inv and shelf_inv:
		update_slots()
		connect_slots()

#start with ui updated
func _ready()->void:
	update_slots()
	connect_slots()

## Binds the slot buttons to send proper signals
func connect_slots()->void:
	if !shelf_inv and !player_inv:
		return
	for i in range(slots.size()):
		var slot:Button = slots[i]
		# disconnect old signal to avoid duplicates
		if slot.has_meta("callback"):
			var old:Callable = slot.get_meta("callback")
			if slot.pressed.is_connected(old):
				slot.pressed.disconnect(old)
		if i < player_slot_count:
			slot.index = i
			slot.inv = player_inv
		# rest must be shelf slots
		else:
			slot.index = i - player_slot_count
			slot.inv = shelf_inv
		var callable : Callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)
		slot.set_meta("callback",callable)

#update each slot in shelf_ui with the info from both inv objects (player_inv + shelf_inv)
## Updates each slot in the UI based on the player and shelf inventory 
func update_slots() ->void:
	if !player_inv or !shelf_inv:
		return
	slots = get_all_slots()
	# Fill first player_slot_count from player inventory
	for i in range(player_slot_count):
		update_single_slot(slots[i], player_inv.slots[i])
	# Fill the rest from shelf inventory
	for i in range(shelf_inv.slots.size()):
		update_single_slot(slots[player_slot_count + i], shelf_inv.slots[i])

## Updates the given [param ui_slot] to reflect the given [param inv_slot].
func update_single_slot(ui_slot: Button, inv_slot: InvSlot) -> void:
	if inv_slot and inv_slot.item:
		if !ui_slot.item_stack:
			var stack:ItemStackUI = ItemStackUIClass.instantiate()
			ui_slot.insert(stack)
			stack.call_deferred("shelf_scale")
		ui_slot.item_stack.invSlot = inv_slot
		ui_slot.item_stack.update_slot()
	else:
		if ui_slot.item_stack:
			ui_slot.container.remove_child(ui_slot.item_stack)
			ui_slot.item_stack.queue_free()
			ui_slot.item_stack = null

## Handles the different scenarios of clicking on a [param slot]. [br][br]
##
## Scenarios are, taking an item, placing an item, stacking items, or swapping.
func on_slot_clicked(slot:Button) -> void:
	if slot.is_empty() and item_on_cursor:
		insert_to_slot(slot)
	elif !item_on_cursor:
		take_from_slot(slot)
	elif slot.item_stack.invSlot.item.equals(item_on_cursor.invSlot.item):
		stack_items(slot)
	else:
		swap_items(slot)

## Places the item from the given [param slot] in the [member item_on_cursor].
func take_from_slot(slot:Button)->void:
	if slot.item_stack:
		item_on_cursor = slot.pick_item()
		add_child(item_on_cursor)
		item_on_cursor.call_deferred("shelf_scale")
		update_cursor()

## Inserts the [member item_on_cursor] to the given [param slot].
func insert_to_slot(slot:Button)->void:
	var item:ItemStackUI = item_on_cursor
	remove_child(item_on_cursor)
	item_on_cursor = null
	slot.insert(item)
	item.call_deferred("shelf_scale")

## Handles switching the places of the [member item_on_cursor] and 
## the given [param slot].
func swap_items(slot:Button)->void:
	var tempItem: ItemStackUI = slot.pick_item()
	
	## In the old inv, at the old slot, put the swapped item (backend only)
	var origin_inv: Inv = item_on_cursor.invSlot.owner	## The former inv
	var origin_idx: int = item_on_cursor.invSlot.index	## Where the old item was
	origin_inv.insert_slot_at(origin_idx, tempItem.invSlot)
	
	insert_to_slot(slot)
	
	item_on_cursor = tempItem
	add_child(item_on_cursor)
	item_on_cursor.call_deferred("shelf_scale")
	update_cursor()

# to have all slots connected, treated as one big array
## Returns a concatenation of the player inventory and the shelf inventory visuals
func get_all_slots() -> Array:
	var list: Array = []
	list.append_array($NinePatchRect2/ShelfPlayerContainer.get_children())
	list.append_array($NinePatchRect/ShelfContainer.get_children())
	return list

## Stacks items from the item_on_cursor to the given slot. Stacking appropriately
## when the stack would be larger than the max stack size.
func stack_items(slot: Button)->void:
	var slotItem: ItemStackUI = slot.item_stack
	var maxNum:int = slotItem.invSlot.item.max_stack_size
	var totalNum:int = slotItem.invSlot.amount + item_on_cursor.invSlot.amount
	
	# if not max slots, need to set original inv slot to 0 and null
	if totalNum<=maxNum:
		slotItem.invSlot.amount = totalNum
		item_on_cursor.invSlot.amount = 0
		item_on_cursor.invSlot.item = null
		remove_child(item_on_cursor)
		item_on_cursor= null
	else:
		slotItem.invSlot.amount = maxNum
		item_on_cursor.invSlot.amount = totalNum-maxNum
	slotItem.update_slot()
	if item_on_cursor:
		item_on_cursor.update_slot()

## Visually updates the position of the [member item_on_cursor].
## Removes the item from the cursor when the UI closes.
func update_cursor()->void:
	if item_on_cursor:
		# additional scale for cursor items
		item_on_cursor.scale = Vector2(5, 5)
		item_on_cursor.global_position = get_global_mouse_position()
	# if shelf ui gets closed while item on cursor, remove item stack ui on cursor
	if item_on_cursor and !self.visible:
		item_on_cursor.queue_free()
		item_on_cursor = null

# Every time the mouse moves, update the cursor visual
func _input(_event:InputEvent)->void:
	update_cursor()

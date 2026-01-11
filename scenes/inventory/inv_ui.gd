extends Control

## Handles the front end representation of the player's inventory.

## All the slots pertaining to the player's inventory
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
## Item stack scene preloaded to be instantiated when necessary
@onready var ItemStackUIClass : PackedScene = preload("res://scenes/inventory/inv_item_stack_ui.tscn")

## Holds the players back end representation of the inventory and 
## connects [signal Inv.update] to [method update_slots].
var inv: Inv:
	set(value):
		#if signal connected, disconnect
		if inv and inv.update.is_connected(update_slots):
			inv.update.disconnect(update_slots)
		inv = value #set to value
		#otherwise connect signal and update the slot ui (render)
		if inv:
			inv.update.connect(update_slots)
			update_slots()
			connect_slots()

## @deprecated: Currently used in player script but unneccessary since this script is solely for player
var allow_hotkeys : bool = false 

## Flags when other inventories are open (like shelf)
var is_open : bool = false

## Holds an item that was clicked by the user
var item_on_cursor: ItemStackUI

#start with ui open and updated
func _ready()->void:
	open()
	update_slots()
	connect_slots()

## Connect the back end and front end of the slots in the player's inventory 
func connect_slots()->void:
	if !inv:
		return
	for i in range(slots.size()):
		var slot:Button = slots[i]
		slot.index = i
		slot.inv = inv
		if i == inv.selected_index:
			slot.select()
		var callable : Callable = Callable(_on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

## Visually updates each slot with the item information in the player's inventory.[br][br]
## [method ItemStackUI.update_slot] gets called for each slot of the inventory.
## See also [Inv]. 
func update_slots()->void:
	if !inv:
		return
	for i in range(min(inv.slots.size(),slots.size())): 
		var invSlot: InvSlot = inv.slots[i]
		if invSlot and invSlot.item:
			var item_stack: ItemStackUI = slots[i].item_stack
			if !item_stack:
				item_stack = ItemStackUIClass.instantiate()
				slots[i].insert(item_stack)
			item_stack.invSlot = invSlot
			item_stack.update_slot()
		else:
			if slots[i].item_stack:
				slots[i].container.remove_child(slots[i].item_stack)
				slots[i].item_stack.queue_free()
				slots[i].item_stack = null

## Visually display the inventory and change state to open
func open() -> void:
	visible = true
	is_open = true
	
## Visually hide the inventory and change state to closed
func close() -> void:
	visible = false
	is_open = false

# Handles clicking a slot in the inventory
func _on_slot_clicked(slot:Button) -> void:
	if slot.is_empty() and item_on_cursor:
		_insert_to_slot(slot)
	elif !item_on_cursor:
		_take_from_slot(slot)
	elif slot.item_stack.invSlot.item.equals(item_on_cursor.invSlot.item):
		_stack_items(slot)
	else:
		_swap_items(slot)

# Handles taking an item from a slot and putting it as the item_on_cursor
func _take_from_slot(slot:Button)->void:
	if slot.item_stack:
		item_on_cursor = slot.pick_item() 
		add_child(item_on_cursor)
		update_cursor()

# Handles placing the item_on_cursor into a slot
func _insert_to_slot(slot:Button)->void:
	var item:ItemStackUI = item_on_cursor
	remove_child(item_on_cursor)
	item_on_cursor = null
	slot.insert(item)

# Handles swapping the item in the slot with item_on_cursor
func _swap_items(slot:Button)->void:
	var tempItem: ItemStackUI = slot.pick_item()
	_insert_to_slot(slot)
	
	item_on_cursor = tempItem
	add_child(item_on_cursor)
	update_cursor()

# Handles placing items from item_on_cursor into the stack in the given slot. 
# Essentially merging them until they hit the max stack size, at which point
# the item_on_cursor will be left with the lesser amount or the two.  
func _stack_items(slot: Button)->void:
	var slotItem: ItemStackUI = slot.item_stack
	var maxNum:int = slotItem.invSlot.item.max_stack_size
	var totalNum:int = slotItem.invSlot.amount + item_on_cursor.invSlot.amount
	
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

## Updates the sprite to be at the mouse's position
func update_cursor()->void:
	if item_on_cursor:
		item_on_cursor.global_position = get_global_mouse_position() - item_on_cursor.size/2

## Each time the mouse moves, updates the item_on_cursor's position using [method update_cursor].
func _input(_event:InputEvent)->void:
	update_cursor()

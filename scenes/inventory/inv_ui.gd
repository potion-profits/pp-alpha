extends Control

#gets all slots in inv_ui scene node's grid container
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var ItemStackUIClass : PackedScene = preload("res://scenes/inventory/inv_item_stack_ui.tscn")
#dynamically sets inv which is set wherever a inventory is to be made
#currently only gets set in player.gd but will later be used in chest, etc
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

#makes script applicable to player and other inventory (chests/shelves)
var allow_hotkeys : bool = false

var is_open : bool = false
var inventory_toggle : bool = true # Setting for toggle vs hold inventory

var item_on_cursor: ItemStackUI

#start with ui closed and updated
#ui is fixed to bottom of screen with size and offset set below
func _ready()->void:
	close()
	update_slots()
	connect_slots()

func connect_slots()->void:
	if !inv:
		return
	for i in range(slots.size()):
		var slot:Button = slots[i]
		slot.index = i
		slot.inv = inv
		var callable : Callable = Callable(on_slot_clicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

#update each slot in inv_ui with the info from the inv object (player_inv)
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

#show inventory
func open() -> void:
	visible = true
	is_open = true
	
#hide inventory
func close() -> void:
	visible = false
	is_open = false

func on_slot_clicked(slot:Button) -> void:
	if slot.is_empty() and item_on_cursor:
		insert_to_slot(slot)
	elif !item_on_cursor:
		take_from_slot(slot)
	elif slot.item_stack.invSlot.item.equals(item_on_cursor.invSlot.item):
		stack_items(slot)
	else:
		swap_items(slot)

func take_from_slot(slot:Button)->void:
	if slot.item_stack:
		item_on_cursor = slot.pick_item() 
		add_child(item_on_cursor)
		update_cursor()

func insert_to_slot(slot:Button)->void:
	var item:ItemStackUI = item_on_cursor
	remove_child(item_on_cursor)
	item_on_cursor = null
	slot.insert(item)

func swap_items(slot:Button)->void:
	var tempItem: ItemStackUI = slot.pick_item()
	insert_to_slot(slot)
	
	item_on_cursor = tempItem
	add_child(item_on_cursor)
	update_cursor()

func stack_items(slot: Button)->void:
	var slotItem: ItemStackUI = slot.item_stack
	var maxNum:int = slotItem.invSlot.item.max_stack_size
	var totalNum:int = slotItem.invSlot.amount + item_on_cursor.invSlot.amount
	
	if totalNum<=maxNum:
		slotItem.invSlot.amount = totalNum
		remove_child(item_on_cursor)
		item_on_cursor= null
		
	else:
		slotItem.invSlot.amount = maxNum
		item_on_cursor.invSlot.amount = totalNum-maxNum
	slotItem.update_slot()
	if item_on_cursor:
		item_on_cursor.update_slot()

func update_cursor()->void:
	if item_on_cursor:
		item_on_cursor.global_position = get_global_mouse_position() - item_on_cursor.size/2

func _input(_event:InputEvent)->void:
	update_cursor()

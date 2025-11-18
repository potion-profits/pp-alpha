extends Control

#gets all slots in inv_ui scene node's grid container
@onready var player_slots: Array = $NinePatchRect2/PlayerContainer.get_children()
@onready var shelf_slots: Array = $NinePatchRect/ShelfContainer.get_children()
@onready var ItemStackUIClass : PackedScene = preload("res://scenes/inventory/inv_item_stack_ui.tscn")

var player_slot_count: int = 5
var shelf_slot_count: int = 12
var slots: Array = player_slots + shelf_slots

var player_inv: Inv
var shelf_inv: Inv

#makes script applicable to player and other inventory (chests/shelves)
var allow_hotkeys : bool = false

var is_open : bool = false
var inventory_toggle : bool = true # Setting for toggle vs hold inventory

var item_on_cursor: ItemStackUI

#dynamically sets inv which is set wherever a inventory is to be made
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

func update_single_slot(ui_slot: Button, inv_slot: InvSlot) -> void:
	if inv_slot and inv_slot.item:
		if !ui_slot.item_stack:
			var stack:ItemStackUI = ItemStackUIClass.instantiate()
			ui_slot.insert(stack)
		ui_slot.item_stack.invSlot = inv_slot
		ui_slot.item_stack.update_slot()
	else:
		if ui_slot.item_stack:
			ui_slot.container.remove_child(ui_slot.item_stack)
			ui_slot.item_stack.queue_free()
			ui_slot.item_stack = null

# depending on slot index, place into player inventory or shelf inventory
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

# to have all slots connected, treated as one big array
func get_all_slots() -> Array:
	var list: Array = []
	list.append_array($NinePatchRect2/PlayerContainer.get_children())
	list.append_array($NinePatchRect/ShelfContainer.get_children())
	return list

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

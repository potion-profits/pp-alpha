extends Control

@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var inv: Inv:
	set(value):
		if inv and inv.update.is_connected(update_slots):
			inv.update.disconnect(update_slots)
		inv = value
		if inv:
			inv.update.connect(update_slots)
			update_slots()

var is_open : bool = false
var inventory_toggle : bool = true # Setting for toggle vs hold inventory
var input_slot_map : Dictionary = {
	KEY_1 : 0,
	KEY_2 : 1,
	KEY_3 : 2,
	KEY_4 : 3,
	KEY_5 : 4,
}

func _ready()->void:
	close()
	update_slots()
	
func update_slots()->void:
	if !inv:
		return
	for i in range(min(inv.slots.size(),slots.size())):
		slots[i].update(inv.slots[i])
		
		
func _input(event: InputEvent) -> void:
	if inventory_toggle:
		if is_open:
			if event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled();
				close()
		else:
			if event.is_action_pressed("inventory"):
				open()
	else:
		if event.is_action_pressed("inventory"):
			open()
		else:
			close()
			
	if is_open:
		for key: Key in input_slot_map:
			var slot : int = input_slot_map[key]
			if Input.is_key_pressed(key):
				slots[slot].select(inv.slots[slot], Vector2(1.1, 1.1))
			else:
				slots[slot].select(inv.slots[slot])
				

func open() -> void:
	visible = true
	is_open = true
	
func close() -> void:
	visible = false
	is_open = false

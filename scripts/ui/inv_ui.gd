extends Control

@onready var inv: Inv = preload("res://inventory/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

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
	update_slots()
	close()
	
func update_slots()->void:
	for i in range(min(inv.items.size(),slots.size())):
		slots[i].update(inv.items[i])
		
		
func _process(_delta: float) -> void:
	if inventory_toggle:
		if Input.is_action_just_pressed("inventory"):
			if is_open:
				close()
			else:
				open()
	else:
		if Input.is_action_pressed("inventory"):
			open()
		else:
			close()
			
	if is_open:
		for key in input_slot_map:
			var slot : int = input_slot_map[key]
			if Input.is_key_pressed(key):
				slots[slot].select(inv.items[slot], Vector2(1.1, 1.1))
			else:
				slots[slot].select(inv.items[slot])
				

func open() -> void:
	visible = true
	is_open = true
	
func close() -> void:
	visible = false
	is_open = false

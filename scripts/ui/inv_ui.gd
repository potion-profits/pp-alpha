extends Control

@onready var inv: Inv = preload("res://inventory/player_inv.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open : bool = false

func _ready()->void:
	update_slots()
	close()
	
func update_slots()->void:
	for i in range(min(inv.items.size(),slots.size())):
		slots[i].update(inv.items[i])
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func open() -> void:
	visible = true
	is_open = true
	
func close() -> void:
	visible = false
	is_open = false

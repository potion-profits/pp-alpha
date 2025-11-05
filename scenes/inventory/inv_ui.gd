extends Control

#gets all slots in inv_ui scene node's grid container
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

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

#makes script applicable to player and other inventory (chests/shelves)
var allow_hotkeys : bool = false
var current_selected_slot: int = -1

var is_open : bool = false
var inventory_toggle : bool = true # Setting for toggle vs hold inventory

#updated to use input map in project settings
var input_slot_map : Dictionary = {
	"slot_1" : 0,
	"slot_2" : 1,
	"slot_3" : 2,
	"slot_4" : 3,
	"slot_5" : 4,
}

#start with ui closed and updated
func _ready()->void:
	close()
	update_slots()
	
#update each slot in inv_ui with the info from the inv object (player_inv)
func update_slots()->void:
	if !inv:
		return
	for i in range(min(inv.slots.size(),slots.size())):
		slots[i].update(inv.slots[i])
		

#handles toggled and held inventory
#esc when toggled will close ui not pause
#esc when held will close and pause
#uses keys to enlarge sprites in inventory
func _input(event: InputEvent) -> void:
	if inventory_toggle:
		if is_open:
			if event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				close()
		else:
			if event.is_action_pressed("inventory"):
				open()
	else:
		if event.is_action_pressed("inventory") and !is_open:
			open()
		elif (event.is_action_released("inventory") or event.is_action_pressed("ui_cancel")) and is_open:
			close()
			
	#only for player inventory
	if is_open and allow_hotkeys:
		for key: StringName in input_slot_map:
			if Input.is_action_just_pressed(key):
				var slot : int = input_slot_map[key]
				#this is a decision, currently doesnt allow picking empty slots
				if !inv.slots[slot] or !inv.slots[slot].item:
					return
				#if something already selected, deselect
				if current_selected_slot !=-1:
					slots[current_selected_slot].deselect(inv.slots[current_selected_slot])
				#change slots
				if current_selected_slot != slot:
					current_selected_slot = slot
					slots[slot].select(inv.slots[slot], Vector2(1.1,1.1))
				#deselect current slot
				else:
					current_selected_slot = -1
			

#show inventory
func open() -> void:
	visible = true
	is_open = true
	
#hide inventory
func close() -> void:
	visible = false
	is_open = false

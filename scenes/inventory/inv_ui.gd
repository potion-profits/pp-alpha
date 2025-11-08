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

var is_open : bool = false
var inventory_toggle : bool = true # Setting for toggle vs hold inventory

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
		

#show inventory
func open() -> void:
	visible = true
	is_open = true
	
#hide inventory
func close() -> void:
	visible = false
	is_open = false

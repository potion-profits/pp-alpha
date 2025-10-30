extends Panel

#texture to be seen in inventory slot
@onready var item_visuals : Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

#updates the texture and amount on given slot and sets visibility
func update(slot: InvSlot) -> void:
	if !slot.item:
		item_visuals.visible = false
		amount_text.visible = false
	else:
		item_visuals.visible = true
		item_visuals.texture = slot.item.texture
		if slot.amount > 1:
			amount_text.visible = true
		amount_text.text = str(slot.amount)
	

#increases the size of the texture in the slot
func select(slot : InvSlot, scaleV: Vector2 = Vector2(.75, .75)) -> void:
	if slot:	
		item_visuals.scale = scaleV

extends Panel
class_name ItemStackUI

@onready var item_visuals : Sprite2D = $item_display
@onready var amount_text: Label = $item_amount

var invSlot : InvSlot

func update_slot()->void:
	if !invSlot or !invSlot.item:
		item_visuals.visible = false
		amount_text.visible = false
	
	else:
		item_visuals.visible = true
		item_visuals.texture = invSlot.item.texture
		if invSlot.amount > 1:
			amount_text.visible = true
		if invSlot.amount <=1:
			amount_text.visible = false
		amount_text.text = str(invSlot.amount)

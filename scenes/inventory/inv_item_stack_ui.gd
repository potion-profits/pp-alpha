extends Panel
class_name ItemStackUI

@onready var item_visuals : Sprite2D = $item_display
@onready var amount_text: Label = $item_amount
@onready var sellable_label: Sprite2D = $sellable_icon
@onready var mixable_label: Sprite2D = $mixable_icon



var invSlot : InvSlot

func update_slot()->void:
	if !invSlot or !invSlot.item:
		item_visuals.visible = false
		amount_text.visible = false
		sellable_label.visible = false
		mixable_label.visible = false
		
	else:
		item_visuals.visible = true
		item_visuals.texture = invSlot.item.texture
		if invSlot.amount > 1:
			amount_text.visible = true
		if invSlot.amount <=1:
			amount_text.visible = false
		amount_text.text = str(invSlot.amount)
		if invSlot.item:
			sellable_label.visible = invSlot.item.sellable
			mixable_label.visible = invSlot.item.mixable
			mixable_label.self_modulate.a = 0.4

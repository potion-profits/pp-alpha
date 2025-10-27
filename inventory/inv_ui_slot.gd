extends Panel

@onready var item_visuals : Sprite2D = $CenterContainer/Panel/item_display
@onready var amount_text: Label = $CenterContainer/Panel/Label

func update(item: InvSlot) -> void:
	if !slot.item:
		item_visuals.visible = false
		amount_text.visable = false
	else:
		item_visuals.visible = true
		item_visuals.texture = item.texture
		amount_text.visable = true
		amount_text.text = str(slot.amount)
	
func select(item: InvItem, scaleV: Vector2 = Vector2(.75, .75)) -> void:
	if item:
		item_visuals.scale = scaleV

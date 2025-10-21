extends Panel

@onready var item_visuals : Sprite2D = $CenterContainer/Panel/item_display

func update(item: InvItem) -> void:
	if !item:
		item_visuals.visible = false
	else:
		item_visuals.visible = true
		item_visuals.texture = item.texture

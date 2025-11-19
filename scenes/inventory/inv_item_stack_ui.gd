extends Panel
class_name ItemStackUI

@onready var item_visuals : Sprite2D = $item_display
@onready var amount_text: Label = $item_amount
@onready var sellable_label: Sprite2D = $sellable_icon
@onready var mixable_label: Sprite2D = $mixable_icon


var invSlot : InvSlot

var texture_scale:float = 1.7
var label_scale:float = texture_scale * 0.25
var label_x_offset:float = -1.25
var label_y_offset:float = -4

func _ready() -> void:
	# if created under the shelf ui, have textures scaled accordingly (There's probably a better way of checking)
	var shelf_ui_container: GridContainer = get_parent().get_parent().get_parent()
	if shelf_ui_container.name == "ShelfContainer" or shelf_ui_container.name == "ShelfPlayerContainer":
		item_visuals.scale = Vector2(texture_scale,texture_scale)
		amount_text.scale = Vector2(label_scale,label_scale)
		sellable_label.scale = Vector2(label_scale,label_scale)
		mixable_label.scale = Vector2(texture_scale,texture_scale)
		
		sellable_label.position = sellable_label.position + Vector2(label_x_offset, label_y_offset)
		amount_text.position = amount_text.position + Vector2(label_x_offset, 0)

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
			mixable_label.self_modulate.a = 0.4 # changes opacity

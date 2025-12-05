extends Panel
class_name ItemStackUI

@onready var item_visuals : Sprite2D = $item_textures/item_display
@onready var amount_text: Label = $item_amount
@onready var sellable_label: Sprite2D = $item_textures/sellable_icon
@onready var mixable_label: Sprite2D = $item_textures/mixable_icon
@onready var item_textures: Node2D = $item_textures

var invSlot : InvSlot

var already_scaled: bool = false
var texture_scale:float = 2.2
var label_scale:float = texture_scale * 0.25
var label_x_offset:float = -6

func _ready() -> void:
	# if created under the shelf ui, have textures scaled accordingly
	var shelf_ui_container: CenterContainer = get_parent()
	if shelf_ui_container and shelf_ui_container.name == "ShelfCenterContainer":
		shelf_scale()

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

#scales texture to fit shelf ui
func shelf_scale() -> void:
	if !already_scaled:
		item_textures.scale = Vector2(texture_scale, texture_scale)
		amount_text.scale = Vector2(label_scale,label_scale)
		amount_text.position = amount_text.position + Vector2(label_x_offset, 0)
		already_scaled = true
	

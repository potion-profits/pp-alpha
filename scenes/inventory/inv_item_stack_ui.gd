extends Panel
class_name ItemStackUI

## Handles the visual representation of an inventory item within a slot.
##
## Manages the scaling, amount information, shaders, and sprites of an item stack.

## Reference to the colored sprite
@onready var item_visuals : Sprite2D = $item_textures/item_display
## Laber reference to the item stack amount
@onready var amount_text: Label = $item_amount
## Reference to the sprite that indicates the item can be sold
@onready var sellable_label: Sprite2D = $item_textures/sellable_icon
## Reference to the shading that indicates the item is mixable
@onready var mixable_label: Sprite2D = $item_textures/mixable_icon
## References the parent node of all the sprites
@onready var item_textures: Node2D = $item_textures

## Holds the slot that this item is under. 
## The slot itself holds the item information.
var invSlot : InvSlot

var already_scaled: bool = false ## Used for scaling when needed
var texture_scale:float = 2.2	## Dictates how big the sprites will be scaled
var label_scale:float = texture_scale * 0.25	## Dictates how big the text will be scaled
var label_x_offset:float = -6	## Position of text in respect to sprites

func _ready() -> void:
	# if created under the shelf ui, have textures scaled accordingly
	var shelf_ui_container: CenterContainer = get_parent()
	if shelf_ui_container and shelf_ui_container.name == "ShelfCenterContainer":
		shelf_scale()

## Visually changes the stack to correctly reflect the item/slot information.
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

## Scales item textures to fit within the shelf UI.
func shelf_scale() -> void:
	if !already_scaled:
		item_textures.scale = Vector2(texture_scale, texture_scale)
		amount_text.scale = Vector2(label_scale,label_scale)
		amount_text.position = amount_text.position + Vector2(label_x_offset, 0)
		already_scaled = true
	

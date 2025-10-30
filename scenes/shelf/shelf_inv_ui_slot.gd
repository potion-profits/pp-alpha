extends TextureRect

# triggers when you click and drag
func _get_drag_data(at_position: Vector2) -> Variant:
	
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(30,30)
	
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	# allows preview to track cursor
	set_drag_preview(preview)
	# remove previous texture
	texture = null
	
	return preview_texture.texture
	
# triggers when you are hover with dragged item
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Texture2D
	
# triggers when you drop that dragged item
func _drop_data(at_position: Vector2, data: Variant) -> void:
	texture = data

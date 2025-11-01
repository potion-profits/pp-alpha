extends TextureRect

var is_dragging = false
var original_texture: Texture2D

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
	original_texture = texture
	texture = null
	is_dragging = true
	
	return preview_texture.texture
	
# triggers when you are over with dragged item
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Texture2D
	
# triggers when you drop that dragged item
func _drop_data(at_position: Vector2, data: Variant) -> void:
	texture = data
	is_dragging = false

func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouse and not event.is_pressed():
		texture = original_texture
		is_dragging = false

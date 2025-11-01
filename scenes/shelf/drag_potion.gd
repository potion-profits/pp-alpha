extends Node2D

var selected = false
var rest_point 
var rest_nodes = []

func _ready() -> void:
	rest_nodes = get_tree().get_nodes_in_group("shelf_zones")
	rest_point = rest_nodes[0].global_position
	
func _on_area_2d_input_event(viewport, event, shape_idx) -> void:
	if Input.is_action_just_pressed("click"):
		selected = true

# Constantly checks scene
func _physics_process(delta: float) -> void:
	if selected:
		# track mouse position
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	else:
		global_position = lerp(global_position, rest_point, 10 * delta)
	
# Allows the item to be released
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			# how far a draggable item will snap to a drop zone (in pixels)
			var shortest_dist = 75 
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position)
				# snap item to that rest point
				if distance < shortest_dist:
					rest_point = child.global_position
					shortest_dist = distance

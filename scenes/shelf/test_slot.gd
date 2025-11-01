extends Marker2D

var marker_color = Color(0,0,0,1)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 50, marker_color)

#func select() -> void:
	#for child in get_tree().get_nodes_in_group("shelf_zones"):
		#child.deslect()
#
#func deselect(): 

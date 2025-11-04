extends Marker2D

var marker_color: Color = Color(0,0,0,0.4)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 8, marker_color)

extends Control

@export var n_options: int = 6
@export var spinners: Array[Control]

var values: Array;
var tween: Tween;

func spin() -> void:
	print("Spinning")
	values = []
	var spin_step: float = 1.0 / float(n_options)
	var offsets: Dictionary = {}
	
	for s in spinners:
		values.append(randi_range(0, n_options - 1))
		var last_pos: float = s.material.get_shader_parameter("y_offset")
		offsets[s] = {"from": last_pos, "to": (last_pos + values[-1] * spin_step) * randi_range(n_options, 3*n_options)}
		
	if tween:
		tween.kill()
		
	tween = get_tree().create_tween()
	tween.tween_method(func (v: float) -> void:
		for s in spinners:
			s.material.set_shader_parameter("y_offset", lerpf(offsets[s]["from"], offsets[s]["to"], v)),
		0.0, 1.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_callback(func () -> void:
		for s in spinners:
			s.material.set_shader_parameter("y_offset", offsets[s]["to"]))
	

shader_type canvas_item;

uniform sampler2D tex : repeat_enable;
uniform float n_rows = 10.0;
uniform float y_offset = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	uv.y /= n_rows;
	uv.y += y_offset;
	COLOR.rgb *= texture(tex, uv).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

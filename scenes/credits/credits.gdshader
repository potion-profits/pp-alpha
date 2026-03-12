shader_type canvas_item;

uniform sampler2D base_image : hint_normal;
uniform sampler2D pixel_image : hint_normal;
uniform float transition : hint_range(0.0, 1.0) = 0.0;

uniform float pixel_size = 10000.0;

void fragment() {
	vec2 uv = UV;
	vec4 base_col = texture(base_image, uv);
	vec2 pixel_uv = floor(uv * pixel_size) / pixel_size;
	vec4 pix_col = texture(pixel_image, pixel_uv);
	
	COLOR = mix(base_col, pix_col, transition);
}

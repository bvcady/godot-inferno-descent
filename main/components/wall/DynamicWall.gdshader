shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform float strength: hint_range(0.001, 0.01) = 0.01;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment () {
	float noiseVal = texture(noise, UV).r;
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV+ noiseVal*strength);
}
shader_type canvas_item;

uniform sampler2D noise : repeat_enable;

void fragment () {
	float noiseVal = texture(noise, UV).r;
	COLOR = texture(TEXTURE, UV + noiseVal/100.0);
}
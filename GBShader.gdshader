shader_type canvas_item;

uniform vec4 lightest: source_color = vec4(0.961, 0.980, 0.937, 1.0);
uniform vec4 light: source_color = vec4(0.549, 0.749, 0.039, 1.0);
uniform vec4 dark: source_color = vec4(0.18, 0.451, 0.125, 1.0);
uniform vec4 darkest: source_color = vec4(0.0, 0.247, 0.0, 1.0);
uniform float lightestThreshold = 0.1;
uniform float lightThreshold = 0.3;
uniform float darkThreshold = 0.6;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	
	float rgb_avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	if (rgb_avg < lightestThreshold) {
		COLOR = vec4(darkest.x, darkest.y, darkest.z, COLOR.a);
	} else if (rgb_avg < lightThreshold) {
		COLOR = vec4(dark.x, dark.y, dark.z, COLOR.a);
	} else if (rgb_avg < darkThreshold) {
		COLOR = vec4(light.x, light.y, light.z, COLOR.a);
	} else {
		COLOR = vec4(lightest.x, lightest.y, lightest.z, COLOR.a);
	}
}
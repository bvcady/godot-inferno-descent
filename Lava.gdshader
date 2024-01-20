shader_type canvas_item;

uniform sampler2D noise : repeat_enable;
uniform sampler2D secondaryNoise : repeat_enable;

uniform float seed = 0;
uniform vec2 scrollSpeed = vec2(0.05, 0.02);
uniform vec2 secondaryScrollSpeed = vec2(0.03, 0.01);

uniform vec4 lightest: source_color = vec4(0.961, 0.980, 0.937, 1.0);
uniform vec4 light: source_color = vec4(0.549, 0.749, 0.039, 1.0);
uniform vec4 dark: source_color = vec4(0.18, 0.451, 0.125, 1.0);
uniform vec4 darkest: source_color = vec4(0.0, 0.247, 0.0, 1.0);
uniform float lightestThreshold = 0.1;
uniform float lightThreshold = 0.3;
uniform float darkThreshold = 0.6;
uniform float rotationSpeed = 5.0;


void fragment () {	
	vec2 dis = vec2(seed, seed);
	vec2 pos = UV + dis;
	vec4 noise_col = texture(noise, (pos + (scrollSpeed * TIME) + vec2(0.5 + sin((TIME + seed)/rotationSpeed), 0.5 -cos((TIME + seed)/rotationSpeed))));
	vec4 secondary_noise_col = texture(secondaryNoise, pos + (secondaryScrollSpeed * TIME) + vec2(0.5 + sin(TIME/rotationSpeed), 0.5 -cos(TIME/rotationSpeed)));
	vec4 one =  vec4(1.0, 1.0, 1.0, 1.0);
	vec4 A = noise_col;
	vec4 B = secondary_noise_col;
	//vec4 mappedValues = one - (one - B)/B;
	
	vec4 mappedValues = one - (A*B * 0.8);

	float rgb_avg = (mappedValues.r + mappedValues.g + mappedValues.b) / 3.0;
	if (rgb_avg < darkThreshold) {
		COLOR = vec4(darkest.x, darkest.y, darkest.z, COLOR.a);
	} else if (rgb_avg < lightThreshold) {
		COLOR = vec4(dark.x, dark.y, dark.z, COLOR.a);
	} else if (rgb_avg < lightestThreshold) {
		COLOR = vec4(light.x, light.y, light.z, COLOR.a);
	} else {
		COLOR = vec4(lightest.x, lightest.y, lightest.z, 0
		);
	}
}
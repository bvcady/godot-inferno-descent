shader_type canvas_item;

const vec2 size = vec2(20, 20);

void fragment() {
    // Calculate the distance from the center of the particle
    float distance = length(FRAGCOORD.xy - vec2(0.5, 0.5) * size);

    // Normalize distance and create a circular shape
    float circle = smoothstep(0.25, 0.24, distance);

    COLOR = vec4(vec3(1.0) - circle, 1.0 - circle);
}
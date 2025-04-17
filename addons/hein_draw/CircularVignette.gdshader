shader_type canvas_item;

uniform float threshold : hint_range(0.0, 2.0);

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv); // Normalized distance from center
    float vignette = 1.0 - smoothstep(1.0,0, dist * threshold);

    COLOR.a *= vignette * 1.0;
}
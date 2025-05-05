shader_type canvas_item;

uniform float softness : hint_range(0.0, 1.0);

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv) * 2.0; // Normalized distance from center
    float clip = 1.0 - smoothstep(1.0 - softness, 1.0, dist);

    COLOR.a = COLOR.a * clip;
}
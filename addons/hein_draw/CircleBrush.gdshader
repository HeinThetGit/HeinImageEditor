shader_type canvas_item;

uniform float vignette_amount : hint_range(0.0, 1.0);

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv) * 2.0; // Normalized distance from center
    float vignette = 1.0 - smoothstep(1.0 - vignette_amount, 1.0, dist);

    COLOR.a = vignette;
}
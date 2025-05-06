shader_type canvas_item;

uniform float threshold : hint_range(0.0, 2.0);
uniform vec4 color : source_color = vec4(1);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv); // Normalized distance from center
    float vignette = 1.0 - smoothstep(1.0,0, dist * threshold);

    COLOR = mix(tex_color, color, vignette);
}
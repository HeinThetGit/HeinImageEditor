shader_type canvas_item;

uniform float size : hint_range(1.0, 100.0) = 25.0;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0); 
uniform vec4 color2 : source_color = vec4(0.7, 0.7, 0.7, 1.0);

void fragment() {
    vec2 pos = floor(FRAGCOORD.xy / size);
    float pattern_mask = mod(pos.x + mod(pos.y, 2.0), 2.0);
    COLOR = mix(color1, color2, pattern_mask);
}
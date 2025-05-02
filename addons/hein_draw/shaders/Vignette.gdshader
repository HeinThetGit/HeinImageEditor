shader_type canvas_item;

//uniform float strength_x : hint_range(0.0, 2.0) = 1.0;
//uniform float strength_y : hint_range(0.0, 2.0) = 1.0;

uniform float softness_x : hint_range(0.001, 0.5) = 0.1;
uniform float softness_y : hint_range(0.001, 0.5) = 0.1;
uniform float threshold : hint_range(0.001, 0.5) = 0.1;
uniform vec2 rect_size = vec2(512.0,512.0);

void fragment() {
    vec2 uv = UV;

    // Distance to horizontal (x) and vertical (y) edges
    float edge_dist_x = min(uv.x, 1.0 - uv.x);
    float edge_dist_y = min(uv.y, 1.0 - uv.y);

    // Vignette effect per axis

    float vignette_x = smoothstep(threshold, 0.0, edge_dist_x);
    float vignette_y = smoothstep(threshold * (rect_size.x / rect_size.y), 0.0, edge_dist_y);

    // Combine both effects
    float vignette = clamp(vignette_x + vignette_y, 0.0, 1.0);
	//float vignette = vignette_x + vignette_y;
    // Output white with transparency based on vignette strength
    COLOR *= vec4(COLOR.rgb,vignette);
}
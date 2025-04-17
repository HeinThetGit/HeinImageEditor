shader_type canvas_item;

//uniform vec4 fill_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float threshold : hint_range(0.0, 100.0) = 20.0;
uniform vec2 rect_size = vec2(256.0, 256.0);

void fragment() {
    vec2 pos = UV * rect_size;
    vec2 dist = min(pos, rect_size - pos);
    float corner_dist = min(dist.x, dist.y);

    // Smooth fade near the corner radius
    float alpha = smoothstep(threshold, threshold - 1.0, corner_dist);
    COLOR.a *= alpha;
}
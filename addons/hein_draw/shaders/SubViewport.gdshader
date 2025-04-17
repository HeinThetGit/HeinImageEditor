shader_type canvas_item;

uniform float threshold : hint_range(0.0, 100.0) = 20.0;
uniform vec2 rect_size = vec2(256.0, 256.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	 vec2 pos = UV * rect_size;
    vec2 dist = min(pos, rect_size - pos);
    float corner_dist = min(dist.x, dist.y);

    // Smooth fade near the corner radius
    float alpha = smoothstep(threshold, threshold - 1.0, corner_dist);
    COLOR = mix(tex_color,vec4(1),alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

uniform float radius = 20.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 size = vec2(textureSize(TEXTURE, 0));
	vec2 uv_pos = UV * size;
	vec2 dist = min(uv_pos, size - uv_pos);
	float corner_dist = min(dist.x, dist.y);
	float alpha = smoothstep(radius - 1.0, radius + 1.0, corner_dist);
	COLOR = vec4(1,1,1,1) * alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;
uniform float threshold : hint_range(0.0, 100.0) = 20.0;
uniform bool grid;
uniform vec2 gridSize = vec2(10.0,10.0);
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
	
	float grid_line = 0.0;
	if (grid){
		//vec2 tex_size = vec2(12,12); // Texture width and height in pixels
    vec2 texel_pos = UV * gridSize;
    float thickness = 0.1;
    float dist_x = min(fract(texel_pos.x), 1.0 - fract(texel_pos.x));
    float dist_y = min(fract(texel_pos.y), 1.0 - fract(texel_pos.y));
    grid_line = step(dist_x, thickness) + step(dist_y, thickness);
	}else{
		grid_line = 0.0;
	}
    //COLOR = mix(tex_color, vec4(0), grid_line);
	
    COLOR = mix(tex_color,vec4(0,0,0,1),alpha + grid_line);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

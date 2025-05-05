shader_type canvas_item;
render_mode blend_sub, unshaded;
uniform float brightness = 2.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float a = COLOR.a;
	vec4 c = COLOR * brightness;
	c.a = a;
	COLOR = c;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

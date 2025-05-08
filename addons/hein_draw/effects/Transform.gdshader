shader_type canvas_item;

uniform vec2 ofc = vec2(0);
uniform float offsetX : hint_range(-1.0, 1.0) = 0.0;
uniform float offsetY : hint_range(-1.0, 1.0) = 0;
uniform float scale : hint_range(-1, 3.0) = 0;
uniform float rotation : hint_range(0, 360,1) = 0;
uniform bool flipX = false;
uniform bool flipY = false;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV + vec2(offsetX, offsetY);
	if (flipY){
		uv.y = (uv.y * -1.0) + 1.0;
	}
	if(flipX){
		uv.x = (uv.x * -1.0) + 1.0;
	}
	uv -= vec2(0.5);
	uv *= 1.0 / (scale + 1.0);
	// Apply rotation
	float rot = radians(rotation + ofc.x);
    float cos_angle = cos(rot);
    float sin_angle = sin(rot);
    mat2 rot_matrix = mat2(
    vec2(cos_angle, -sin_angle),
    vec2(sin_angle,  cos_angle)
	);
    uv *= rot_matrix;

	uv += vec2(0.5);
	vec4 tex = texture(TEXTURE, uv);
	float mask = step(uv.x, 1) * step(uv.y, 1);
	mask *= step(0, uv.x);
	mask *= step(0, uv.y);
	tex.a *= mask;
	COLOR = tex;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

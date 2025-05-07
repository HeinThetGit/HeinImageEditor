shader_type canvas_item;

uniform bool mirror_horizontal = true; // true = mirror left-to-right, false = top-to-bottom
uniform float mirror_position : hint_range(0.0, 1.0) = 0.0; // Where to start the mirror (as UV position 0–1)

void fragment() {
    vec2 uv = UV;

    if (mirror_horizontal) {
        if (uv.x > mirror_position) {
            float mirrored_x = mirror_position - (uv.x - mirror_position);
            uv.x = clamp(mirrored_x, 0.0, 1.0);
        }
    } else {
        if (uv.y > mirror_position) {
            float mirrored_y = mirror_position - (uv.y - mirror_position);
            uv.y = clamp(mirrored_y, 0.0, 1.0);
        }
    }

    COLOR = texture(TEXTURE, uv);
}

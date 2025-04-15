shader_type canvas_item;

uniform sampler2D my_texture : source_color;
uniform vec4 tint_color : source_color = vec4(1);
uniform vec2 uv_scale = vec2(1.0, 1.0); // How many times the texture repeats per screen unit

void fragment() {
    // Use SCREEN_UV to keep texture tiling consistent globally
    vec2 tiled_uv = SCREEN_UV * uv_scale;

    vec4 tex_color = texture(my_texture, tiled_uv);
    COLOR = tex_color * tint_color;
}
shader_type canvas_item;

uniform sampler2D source_texture;

void fragment() {
    vec2 tex_size = vec2(10,10); // Texture width and height in pixels
    vec2 texel_pos = UV * tex_size;
    float thickness = 0.02;
    float dist_x = min(fract(texel_pos.x), 1.0 - fract(texel_pos.x));
    float dist_y = min(fract(texel_pos.y), 1.0 - fract(texel_pos.y));
    float grid_line = step(dist_x, thickness) + step(dist_y, thickness);
    vec4 tex_color = texture(source_texture, UV);
    COLOR = mix(tex_color, vec4(0), grid_line);
}

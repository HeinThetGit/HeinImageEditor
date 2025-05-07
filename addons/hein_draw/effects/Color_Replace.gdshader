shader_type canvas_item;

uniform vec4 target_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Color to replace (e.g., red)
uniform vec4 new_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);    // Replacement color (e.g., green)
uniform float threshold : hint_range(-1, 1.0) = 0.0;      
const float offset = 0.8;          // How close the color needs to match

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    float diff = distance(tex_color.rgb, target_color.rgb);
    float blend = smoothstep(threshold + offset, 0.0, diff); // 1 if close, 0 if far

    vec4 final_color = mix(tex_color, new_color, blend);
    final_color.a *= tex_color.a; // preserve original alpha
    COLOR = final_color;
}

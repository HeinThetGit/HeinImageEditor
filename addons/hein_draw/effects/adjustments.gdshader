shader_type canvas_item;
uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast : hint_range(-1.0, 1.0) = 0.0;
uniform float saturation : hint_range(-1, 3.0) = 0.0;
uniform float tint_intensity : hint_range(-1, 3.0) = 0.0;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Apply tint
	float gray = dot(tex_color.rgb,vec3(0.299, 0.587, 0.114));
	tex_color.rgb = mix(vec3(1)*gray, tex_color.rgb, saturation + 1.0);
    tex_color.rgb *= tint_color.rgb * tint_intensity + 1.0;

    // Apply brightness
    tex_color.rgb += brightness;

    // Apply contrast
    tex_color.rgb = (tex_color.rgb - 0.5) * (1.0 + contrast) + 0.5;

    COLOR = vec4(tex_color.rgb, tex_color.a * tint_color.a);
}
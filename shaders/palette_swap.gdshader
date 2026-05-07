shader_type canvas_item;

uniform sampler2D original_palette;
uniform sampler2D new_palette;

uniform int colors_count = 8;
uniform float tolerance = 0.01;
uniform float brightness = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	
	vec2 new_uv = vec2(0.0, 0.5);
	bool found = false;

	for (int i = 0; i < colors_count; i++) {
		float u = (float(i) + 0.5) / float(colors_count);
		vec2 uv = vec2(u, 0.5);

		vec4 palette_color = texture(original_palette, uv);

		float dist = distance(color.rgb, palette_color.rgb);

		if (dist < tolerance) {
			new_uv = uv;
			found = true;
			break;
		}
	}

	if (found) {
		COLOR = texture(new_palette, new_uv);
		COLOR.rgb *= brightness;
		COLOR.a = color.a;
	} else {
		COLOR = color;
		COLOR.rgb *= brightness;
	}
}
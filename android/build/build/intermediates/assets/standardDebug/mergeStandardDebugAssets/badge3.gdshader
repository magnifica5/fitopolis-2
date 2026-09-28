shader_type canvas_item;

uniform bool grayscale_enabled = true;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	if (grayscale_enabled) {
		float gray = dot(
			color.rgb,
			vec3(0.299, 0.587, 0.114)
		);

		color.rgb = vec3(gray);
	}

	COLOR = color;
}
shader_type canvas_item;

uniform float alpha;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a == 0.0) discard;
	COLOR = color * clamp(sin(TIME*15.0 - UV.y * 7.0)*2.0, 0.9, 1.2);
	COLOR.a = alpha;
}

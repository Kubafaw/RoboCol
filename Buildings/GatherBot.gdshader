shader_type canvas_item;

uniform float fullness;

void fragment() {
	if (COLOR == vec4(1.0, 1.0, 1.0, 1.0)) {
		COLOR = vec4(1.0 - fullness, fullness, 0.0, 1.0);
	}
}


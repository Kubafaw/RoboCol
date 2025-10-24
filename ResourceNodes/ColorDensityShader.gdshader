shader_type canvas_item;

uniform float red_density;
uniform float green_density;
uniform float blue_density;
uniform float y_range;

void fragment() {
	if (UV.y < y_range && (COLOR.r != COLOR.g && COLOR.r != COLOR.b))
		COLOR.rgb = vec3(COLOR.r * red_density, COLOR.g * green_density, COLOR.b * blue_density);
}
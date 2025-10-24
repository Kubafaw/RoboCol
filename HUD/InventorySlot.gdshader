shader_type canvas_item;

uniform vec4 _color : source_color = vec4(1.0);
uniform float _distance_modifier = 1.0;
uniform float _time_modifier = 1.0;
uniform float _brightness_modifier = 1.0;

void fragment() {
	float _distance = distance(vec2(0.5, 0.5), UV.xy) * _distance_modifier;
	vec4 new_color = vec4(_color.rgb * (1.0 - _distance), 0.8);
	if (length(new_color.rgb) < 0.30)
		new_color.a = 0.0;
	COLOR = (new_color * clamp(1.0 - sin(TIME*3.0) * _time_modifier, 0.5, 1.0)) * _brightness_modifier ;
}



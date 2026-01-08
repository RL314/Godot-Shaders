shader_type canvas_item;

void fragment() {
	vec2 uvCentered = UV - vec2(.5);
	float angle = atan(uvCentered.y, uvCentered.x); // not the real atan, wich is overloaded as atan(y,x)

	COLOR = vec4(vec3(angle), 1.);
}

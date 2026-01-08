shader_type canvas_item;

const float TWO_PI = 6.2832;

void fragment() {
	float sym = 5.;
	float omega = TWO_PI / sym;
	vec3 c3 = vec3(0);

	vec2 uvCentered = UV - vec2(.5);
	float angle = atan(uvCentered.y, uvCentered.x);
	float r = length(uvCentered);

	float d = (
			cos(floor(.5+angle/omega)*omega-angle)
			+ fract(abs(cos(angle*sym/2.)))*.2
			+ fract(pow(abs(sin(angle*sym/2.)), 1.5))*.3
	)*r ;

	// (a) field plot. z(x,y)
	c3 = vec3(d);

	// (b) transition at designated z value
	c3 = vec3(1.0-smoothstep(.2,.21,d));

	COLOR = vec4(c3,1.);
}

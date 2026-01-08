shader_type canvas_item;


const float TWO_PI = 6.2832;

vec2 tile(vec2 uv, float periods){
	return fract(uv*periods) - vec2(.5);
}

vec2 rotate2D(vec2 uvCentered, float angle){
    return mat2(
			vec2(cos(angle), sin(angle)), 
			vec2(-sin(angle), cos(angle))
	)* uvCentered;
}


float myStar(float sym, float angle, float r, float scale){
	float omega = TWO_PI / sym;
	
	float d = (
			cos(floor(.5+angle/omega)*omega-angle)
			+ fract(abs(cos(angle*sym/2.)))*.2
			+ fract(pow(abs(sin(angle*sym/2.)), 1.5))*.3
	)*r ;
	
	return d / scale;
}

void fragment() {
	float sym = 4.;
	vec3 c3 = vec3(0);
	
	vec2 uvCentered = tile(UV, 4.);
	uvCentered = rotate2D(uvCentered, 0.33);
	float angle = atan(uvCentered.y, uvCentered.x);
	float r = length(uvCentered);
	
	float d = myStar(sym, angle, r, 2.8);
	
	c3 = vec3(1.0-smoothstep(.2,.21,d));
	
	COLOR = vec4(c3, 1.);
}

shader_type canvas_item;


uniform float R;


// step() and smoothstep() are removed in Godot 4.4 ???
//float smoothstep(float e1, float e2, float x){
	//// a step function, but transit smoothly between (the x-value of) e1 and e2
	//// not to be confused with lerp
	//float t = clamp((x - e1) / (e2 - e1), 0.0, 1.0);
	//return t * t * (3.0 - 2.0 * t);
//}

void fragment() {
	float sym = 3.;
	vec3 c3 = vec3(0);
	
	vec2 uvCentered = UV - vec2(.5);
	float angle = atan(uvCentered.y, uvCentered.x);
	float r = length(uvCentered)*2.5;
	
	float f = cos(angle*sym);
//	f = abs(cos(angle*2.5));
//	f = abs(cos(angle*2.5))*.5+.3;
//	f = abs(cos(angle*12.)*sin(angle*3.))*.8+.1;
//	f = smoothstep(-.5,1., cos(angle*10.))*0.2+0.5;
	
	// (a) field plot. z(x,y)
	//c3 = vec3(f);
	
	// (b) transition at designated z value
	c3 = vec3( 1. - smoothstep(f,f+.1,r) );
	
	
	// (c) contour (the most illustrative)
//	if((abs(fract((f-r)*8.)) < 0.06)){
//		c3 = vec3(1.);
//	}
	
	COLOR = vec4(c3, 1.);
}

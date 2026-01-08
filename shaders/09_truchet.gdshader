shader_type canvas_item;

uniform float n; // number of rows and columns

//float smoothstep(float e1, float e2, float x){
	//// a step function, but transit smoothly between (the x-value of) e1 and e2
	//// not to be confused with lerp
	//float t = clamp((x - e1) / (e2 - e1), 0.0, 1.0);
	//return t * t * (3.0 - 2.0 * t);
//}

vec2 tileUV(vec2 uv, float periods){
	return fract(uv*periods) - vec2(.5);
}
vec2 tileRC(vec2 uv, float periods){
	return floor(uv*periods);
}
float truchet(vec2 uvCentered, vec2 cr){
	// cr-wise random function
	float s = fract(sin(dot(cr, vec2(-404.56221, 211.00377))) * (352776.22113+TIME/8.));
	
	if(s < .45){
		return smoothstep(-.1/n-.1, .1/n+.1, abs(uvCentered.x+uvCentered.y));
	}else if(s > .55){
		return smoothstep(-.1/n-.1, .1/n+.1, abs(uvCentered.x-uvCentered.y));
	}else{
		return 1.;
	}
}


void fragment() {
	vec3 c3 = vec3(0);
	
	vec2 uv = tileUV(UV, n); // centered
	vec2 cr = tileRC(UV, n);
	
	float d = truchet(uv, cr);
	
	c3 = vec3(d);
	
	COLOR = vec4(c3, 1.);
}

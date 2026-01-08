shader_type canvas_item;


const float TWO_PI = 6.2832;
const float animPeriod = 4.;
const float animHalfPeriod = 2.;

uniform float periods; 

vec2 tileUV(vec2 uv, float _periods){
	return fract(uv*_periods) - vec2(.5);
}
vec2 tileRC(vec2 uv, float _periods){ // compute row and column
	//return sign(uv) * ceil(abs(uv*_periods));
	return ceil(uv*_periods);
}

vec2 signRC(vec2 cr){
	// for each cordinate, set to -1 if even, +1 if odd
	return sign(mod(cr,2.)-.5);
}

vec2 animate(vec2 uv, float t, vec2 cr){
	// (1,0) if x, (0,1) if y
	vec2 dir = vec2(float(int(mod(t, animPeriod) < animHalfPeriod)), 0.);
	dir.y = 1. - dir.x;

	vec2 displacement = vec2(mod(t, animHalfPeriod) / animHalfPeriod);
	displacement *= dir * signRC(cr).yx;
	displacement *= dir;
	
	vec2 uv_ = fract(uv + displacement+vec2(.5)) - vec2(.5);
	return uv_;
}

//float smoothstep(float e1, float e2, float x){
	//float t = clamp((x - e1) / (e2 - e1), 0.0, 1.0);
	//return t * t * (3.0 - 2.0 * t);
//}

float circle(float r, float scale){
	return smoothstep(scale-.05, scale+.05, r);
}

void fragment() {
	float sym = 5.;
	vec3 c3 = vec3(0);
	
	vec2 uvCentered = tileUV(UV, periods);
	vec2 cr = tileRC(UV, periods);
	uvCentered = animate(uvCentered, TIME, cr);
	
	float r = length(uvCentered);
	
	float d = 1.-circle(r, .28);
	
	// (z-1) grid
	//c3 = vec3(cr.x/periods, cr.y/periods, 0.);
	// (z-2) cr odd even
	//c3 = vec3(.5 + signRC(cr)*.5
	
	c3 = vec3(1.0-smoothstep(.2,.21,d));
	
	
	COLOR = vec4(c3, 1.);
}

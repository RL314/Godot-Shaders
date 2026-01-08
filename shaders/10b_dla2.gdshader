shader_type canvas_item;

// adapted from https://www.shadertoy.com/view/ldK3RW

// time-constant
uniform vec2 size;
uniform float conc; // fluid concentration
uniform sampler2D noise;
uniform vec2 nucleusXY = vec2(64, 120);
uniform int seed;
// time-variant
uniform int iFrame;
uniform sampler2D lastFrame;

const vec3 mod3 = vec3(.1031,.11369,.13787);
float hash13(vec3 p3) {
	p3 = fract(p3 * mod3);
    p3 += dot(p3, p3.yzx+19.19);
    return fract((p3.x + p3.y)*p3.z);
}
float hash13(ivec3 p){
	// https://www.shadertoy.com/view/XdGfRR
	uvec3 q = uvec3(p) * uvec3(1597334673U, 3812015801U, 2798796415U);
	uint n = (q.x ^ q.y ^ q.z) * 1597334673U;
	return float(n) * 2.328306437080797e-10;
}
int diffuseDirection(int x, int y){
	return int(4. * hash13(vec3(ivec3(x, y, iFrame))));
}

vec4 colorInitialState(vec2 uv){
	vec2 xy = uv * size;
	// (0) the initial state
	float r = length(xy - nucleusXY);

	// (0-a) nucleus
	if(r < 2.){
		return vec4(0,1,0,1);
	}
	
	// (0-c) border
	if(xy.x < 1. || xy.x > size.x - 1.5 ||
		xy.y < 1.){
		return vec4(1,0,0,1);
	}
	else if(r > 6. && texture(noise, uv).r < conc){ // speed things up
		return vec4(1,0,0,1);
	}
	return vec4(0,0,0,1);
}

vec4 nextState(vec2 uv){
	vec4 c = texture(lastFrame, uv);
	// (1a) is solid
	if(c.g > .5){
		return vec4(0,1,0,1);
	}
	
	ivec2 xyInt = ivec2(uv * size);
	
	// (1e) border
	if((xyInt.x == 0 || xyInt.x == int(size.x)-1) ||
		xyInt.y == 0){
		return vec4(1,0,0,1);
	}
	
	// we tested that texelFetch() always returns vec4(0)
	// if it takes coordinates outside the boundary of the texture
	int x0 = xyInt.x - 1;
	int x1 = xyInt.x;
	int x2 = xyInt.x + 1;
	int y0 = xyInt.y - 1;
	int y1 = xyInt.y;
	int y2 = xyInt.y + 1;
	vec4 n  = texelFetch(lastFrame, ivec2(x1, y0), 0);
	vec4 ne = texelFetch(lastFrame, ivec2(x2, y0), 0);
	vec4 e  = texelFetch(lastFrame, ivec2(x2, y1), 0);
	vec4 se = texelFetch(lastFrame, ivec2(x2, y2), 0);
	vec4 s  = texelFetch(lastFrame, ivec2(x1, y2), 0);
	vec4 sw = texelFetch(lastFrame, ivec2(x0, y2), 0);
	vec4 w  = texelFetch(lastFrame, ivec2(x0, y1), 0);
	vec4 nw = texelFetch(lastFrame, ivec2(x0, y0), 0);
	
	// The original implementation allows a particle to aggregate 
	// onto the solid surface and then diffuse away. 
	// Since the particle leaves the free space only when it diffuse 
	// into the solid (i.e. to a green cell), each particle tends to 
	// leave a continuous trail of aggregation. 
	// The result is that
	// 1) The aggregation proceeds more quickly. 
	// 2) Branches often join together. 
	if(iFrame % 2 == 0){
		// (1b) aggregation
		if(c.r > .5 &&
			(n.g + ne.g + e.g + se.g + s.g + sw.g + w.g + nw.g) > .5
		){
			return vec4(0,1,0,1);
		}else{
			return c;
		}
	}else{
		// (1c) diffusion
		// approx whether the closest 4 cells diffuse to this pixel
		// The extra term somewhat maintains the concentration. 
		// Note that when two particles enter the one pixel on any one frame, they become one particle. 
		bool nDiff = n.r > .5 && diffuseDirection(x1, y0) == 0;
		bool eDiff = e.r > .5 && diffuseDirection(x2, y1) == 1;
		bool sDiff = s.r > .5 && diffuseDirection(x1, y2) == 2;
		bool wDiff = w.r > .5 && diffuseDirection(x0, y1) == 3;
		if(nDiff || eDiff || sDiff || wDiff ||
			(1.+(n.r + e.r + s.r + w.r)/64.) * hash13(ivec3(y1, iFrame, x1+seed)) > 1.){ // has artifact
			return vec4(1,0,0,1);
		}
	}
	return vec4(0,0,0,1);
}

void fragment() {
	// (0) the initial state
	if(iFrame < 8){
		COLOR = colorInitialState(UV);
	}

	 // (1) step
	else{
		COLOR = nextState(UV);
	}


	//COLOR = testInitial(UV);

	// It appears that texelFetch() always returns vec4(0)
	// if it takes a coordinates outside the boundary of the texture
	//
	//ivec2 xyInt = ivec2(UV * size);
	//float a = texelFetch(lastFrame, xyInt*776677, 0).a;
	//COLOR = vec4(a, a, a, 1);
}



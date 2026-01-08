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

float hash13(vec3 p3){ // https://www.shadertoy.com/view/4djSRW
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}
int diffuseDirection(int x, int y){
	return int(4. * hash13(vec3(ivec3(x, y, iFrame))));
}

vec4 colorInitialState(vec2 uv){
	vec2 xy = uv * size;
	// (0) the initial state
	float r = length(xy - nucleusXY);

	// (0-1) nucleus
	if(r < 2.){
		return vec4(0,1,0,1);
	}
	// (0-2) initial fluid distribution
	else if(r < 15. && r > 6.
		&& texture(noise, uv).r < conc
	){
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

	// (1b) aggregation
	if(c.r > .5 &&
		(n.g + ne.g + e.g + se.g + s.g + sw.g + w.g + nw.g) > .5
	){
		return vec4(0,1,0,1);
	}
	
	// (1c) diffusion
	// approx whether the closest 4 cells diffuse to this pixel
	bool nDiff;
	if(y0 >= 0){
		if(n.r < .5){
			nDiff = false;
		}else{
			nDiff = diffuseDirection(x1, y0) == 0;
		}
	}else{
		nDiff = (
			hash13(vec3(ivec3(y0, iFrame, x1+seed))) < conc && // whether the exterior pixel has fluid particle
			diffuseDirection(x1, y0) == 0
		);
	}
	bool eDiff;
	if(x2 < int(size.x)-1){
		if(e.r < .5){
			eDiff = false;
		}else{
			eDiff = diffuseDirection(x2, y1) == 1;
		}
	}else{
		eDiff = (
			hash13(vec3(ivec3(y1, iFrame, x2+seed))) < conc && // whether the exterior pixel has fluid particle
			diffuseDirection(x2, y1) == 1
		);
	}
	bool sDiff;
	if(y2 < int(size.y)-1){
		if(s.r < .5){
			sDiff = false;
		}else{
			sDiff = diffuseDirection(x1, y2) == 2;
		}
	}else{
		sDiff = (
			hash13(vec3(ivec3(y2, iFrame, x1+seed))) < conc && // whether the exterior pixel has fluid particle
			diffuseDirection(x1, y2) == 2
		);
	}
	bool wDiff;
	if(x0 >= 0){
		if(w.r < .5){
			wDiff = false;
		}else{
			wDiff = diffuseDirection(x0, y1) == 3;
		}
	}else{
		wDiff = (
			hash13(vec3(ivec3(y1, iFrame, x0+seed))) < conc && // whether the exterior pixel has fluid particle
			diffuseDirection(x0, y1) == 3
		);
	}

	if(nDiff || eDiff || sDiff || wDiff){
		return vec4(1,0,0,1);
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



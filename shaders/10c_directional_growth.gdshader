shader_type canvas_item;

const ivec2 neighborArray[] = {
	ivec2( 0,-1), ivec2( 1, 0), ivec2( 0, 1), ivec2(-1, 0), 
	ivec2(-1, 1), ivec2(-1,-1), ivec2( 1, 1), ivec2( 1,-1)
};
const mat2 rotateMatPos = mat2(vec2(0.5, 0.866), vec2(-0.866, 0.5));
const mat2 rotateMatNeg = mat2(vec2(0.5,-0.866), vec2( 0.866, 0.5));
// time-constant
uniform vec2 size;
uniform int seed;
uniform float halfWidth;
uniform float branchingProb;
uniform sampler2D branchingProbNoise;
// time-invaraint
uniform int iFrame;
uniform sampler2D lastFrame;

// The vec4 of each pixel represents (x1, y1, x2, y2), 
// corresponding to the straight line passing through (x1,y1) and (x2,y2)
// (x1,y1) is a point within the texture.
// (x2,y2) is a point supposedly outside of the texture. 
// 0 = the central pixel
// ±1 = the 1000th pixel on the ±side
bool isOccupied(vec4 c){
	return c.z > 0.01 || c.w > 0.01; // (x2,y2) is empty iff (x2,y2)=(0,0)
}
ivec2 uv2xyC(vec2 uv){
	return ivec2(floor((uv-vec2(.5)) * size));
}
vec2 xy2color(vec2 xyC){
	return mix(vec2(0), vec2(1), 
		(xyC + 512.) / 1024.
	);
}
vec2 color2xy(vec2 color){
	return mix(vec2(-512), vec2(512), color);
}
float shoelaceFormula(vec2 p1, vec2 p2, vec2 p3){ // +ve or -ve
	return (determinant(mat2(p1,p2)) + determinant(mat2(p2,p3)) + determinant(mat2(p3,p1))) * .5;
}
float orthDist(vec2 xy, vec4 c){
	vec2 x1y1 = color2xy(c.xy);
	vec2 x2y2 = color2xy(c.zw);
	float area = shoelaceFormula(xy, x1y1, x2y2);
	return abs(area / length(x2y2 - x1y1) * 2.);
}

float computeRotateVecScale(vec2 xyC, vec2 rotateVec){
	float a = dot(rotateVec, rotateVec);
	float b = 2. * dot(xyC, rotateVec);
	
	return (-b 
		+ sqrt(b*b - 4. * a * (dot(xyC, xyC) - 500.*500.))
	) / 2. / a;
}
 
// maths ----
float hash13(ivec3 p){
	// https://www.shadertoy.com/view/XdGfRR
	uvec3 q = uvec3(p) * uvec3(1597334673U, 3812015801U, 2798796415U);
	uint n = (q.x ^ q.y ^ q.z) * 1597334673U;
	return float(n) * 2.328306437080797e-10;
}

// mains ----
vec4 colorInitialState(vec2 uv){
	ivec2 xyIntC = uv2xyC(uv);
	
	// (a) the central pixel points downwards (a=1. for easy debug)
	if(xyIntC.x == 0 && xyIntC.y == 0){
		return vec4(
			xy2color(vec2(-.5,-.5)), 
			xy2color(vec2(-.5, 500))
		);
	}else if(xyIntC.x == -1 && xyIntC.y == -1){
		return vec4(
			xy2color(vec2(-.5,-.5)), 
			xy2color(vec2(-.5, -500)) // will not work if it is the alpha=0 value. I suspect the viewport texturetreats any RGBA color with 0 alpha as (0,0,0,0) and the blue channel is lost (becomes not occupied)
		);
	}
	// (b)
	return vec4(0);
}

vec4 nextState(vec2 uv){
	ivec2 xyIntC = uv2xyC(uv);
	vec4 c = texelFetch(lastFrame, xyIntC+ivec2(size/2.), 0);
	if(isOccupied(c)){
		return c;
	}
	
	vec4 nc_ = vec4(0); // color of the neighbor it is grwoing from
	vec2 nToSelf; // the displacement vector from the neighbor to this pxel
	int occupiedNeighbors = 0; // for occlusion
	for(int i=0; i<8; i++){
		ivec2 nxyIntC = xyIntC + neighborArray[i];
		vec4 nc = texelFetch(lastFrame, nxyIntC+ivec2(size/2.), 0);
		if(isOccupied(nc)){
			occupiedNeighbors += 1;
			if(occupiedNeighbors == 1){ //!! directional preference
				nc_ = nc;
				nToSelf = -vec2(neighborArray[i]);
			}
		}
	}
	if(occupiedNeighbors == 0){
		return vec4(0);
	}
	// !!!
	//return vec4(nc_);
	// this check reveals unmistably that Godot is incapable of retrieving the color set for lastFrame. 
	// For every frame, in which the color propagates to a neighboring pixel, 
	// the color is contaminated by the background (which I set to transparent on every SubViewport),
	// so you are going to see a square that darkens in color from inside out. 
	
	// (a) axial grwoth
	float dr = orthDist(vec2(xyIntC), nc_) - halfWidth;
	float dr_ = dr / halfWidth;
	float diffusionProb = hash13(ivec3(xyIntC, iFrame+seed));
	if(dr < 0. && diffusionProb < dr_*dr_){
		return nc_;
	}
	// (c) occlusion
	if(occupiedNeighbors > 3){
		return vec4(0);
	}
	// (b) branching
	// technically it branches off everywhere if given enough time
	// slns: 
	// 1. dla
	// 2. have a noise that determines which spots can branch <-
	float p = texelFetch(branchingProbNoise, xyIntC + ivec2(size/2.), 0).r;
	if(diffusionProb < p * branchingProb){
		// (1) determine direction of new branch
		vec2 rootVec = color2xy(nc_.zw) - color2xy(nc_.xy);
		vec2 rotateVec = rotateMatPos * rootVec; // new dir
		vec2 rotateNeg = rotateMatNeg * rootVec; // no sqrt cheaper?
		if(dot(rotateNeg, nToSelf) > dot(rotateVec, nToSelf)){
			rotateVec = rotateNeg;
		} 
		// we search for t s.t. ||xyIntC + t * rotateVec|| = 512, applying the quadratic formula
		vec2 x2y2 = vec2(xyIntC) + rotateVec * computeRotateVecScale(vec2(xyIntC), rotateVec);
		return vec4(
			xy2color(vec2(xyIntC)), 
			xy2color(x2y2)
		);
	}
	
	return vec4(0);
}

void fragment() {
	// (0) the initial state
	if(iFrame < 2){
		COLOR = colorInitialState(UV);
	}
	//  (1) step
	else{
		COLOR = nextState(UV);
	}
	//ivec2 xyIntC = ivec2(-1,-1);
	////vec4 c = texelFetch()
	//vec4 c = vec4(
		//xy2color(vec2(-.5,-.5)), 
		//xy2color(vec2(-.5, -500))
	//);
	//vec2 x1y1 = color2xy(c.xy);
	//vec2 x2y2 = color2xy(c.zw);
	//float area = abs(shoelaceFormula(vec2(ivec2(-1,0)), x1y1, x2y2));
	//float d = orthDist(vec2(ivec2(-1,0)), c);//abs(area / length(x2y2 - x1y1) * 2.);
	//if(d == .5){
		//COLOR = vec4(1,0,0,1);
	//}else{
		//COLOR = vec4(0);
	//}
	
	//ivec2 xyIntC = uv2xyC(UV);
	//COLOR = vec4(
		//xy2color(vec2(xyIntC)), 
		//0, 1
	//);
	//COLOR = texelFetch(branchingProbNoise, xyIntC + ivec2(size/2.), 0);
	
	
	//ivec2 xyIntC = ivec2(1, -4);
	//vec2 color = xy2color(vec2(xyIntC));
	//vec2 xyC = color2xy(color);
	//if(xyC.x == 1.){
		//COLOR = vec4(1,0,0,1);
	//}
}



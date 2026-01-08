shader_type canvas_item;

uniform vec2 size;


float hash13(ivec3 p){
	// https://www.shadertoy.com/view/XdGfRR
	uvec3 q = uvec3(p) * uvec3(1597334673U, 3812015801U, 2798796415U);
	uint n = (q.x ^ q.y ^ q.z) * 1597334673U;
	return float(n) * 2.328306437080797e-10;
}

void fragment() {
	ivec2 xyInt = ivec2(UV * size);
	int iFrame = int(TIME);

	ivec3 v = ivec3(xyInt.xy, iFrame);

	float c = hash13(v);
	COLOR = vec4(c,c,c, 1);
}

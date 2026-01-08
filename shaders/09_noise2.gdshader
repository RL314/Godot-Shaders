shader_type canvas_item;

uniform float n;
uniform sampler2D noise;


float random(vec2 cr){
	// you need the floor for floor(cr)
	// otherwise Godot would mess up b,c,d points by some wild rounding
	return fract(sin(dot(floor(cr), vec2(22.2225, 8.5006))) * -50502.4431 + TIME /12.);
}

vec3 smoothstep2D(vec2 uv, vec2 cr){
	float a = random(cr);
	float b = random(cr + vec2(1,0));
	float c = random(cr + vec2(0,1));
	float d = random(cr + vec2(1,1));
	
	vec2 t = uv * uv * (3. - 2.*uv);
	
	float z = mix(a, b, t.x) +
		(c - a)* t.y * (1.0 - t.x) +
		(d - b) * t.y * t.x;
	// a,b,c,d ∈ [0,1)
	// |∇z| ∈ [-1,1]
	float dzdx = (b-a) - 
			(c-a) * t.y +
			(d-b) * t.y;
	float dzdy = (c-a)*(1.-t.x) + (d-b)*t.x;
	
	return vec3(dzdx*.5+.5, dzdy*.5+.5, z);
}

void fragment() {
	vec3 c3 = vec3(0);
	
	vec2 uv = fract(UV*n); // do not have to center
	vec2 cr = floor(UV*n);
	
	c3 = smoothstep2D(uv, cr);
	
	COLOR = vec4(c3, 1.);
}

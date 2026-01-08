shader_type canvas_item;


// https://thebookofshaders.com/11/

uniform float n;

// designate a vector to each vortex
vec2 random2D(vec2 cr){
	//cr = floor(cr);
    vec2 v = vec2(
			dot(cr,vec2(342.2,289.7)),
    		dot(cr,vec2(124.8,163.9))
	);
    return -1.0 + 2.0*fract(sin(v)*20204.7711); // [-1, 1)
}
vec2 smoothstep2D(vec2 cr, vec2 uv){
	vec2 a = random2D(cr);
	vec2 b = random2D(cr + vec2(1,0));
	vec2 c = random2D(cr + vec2(0,1));
	vec2 d = random2D(cr + vec2(1,1));
	
	vec2 t = uv * uv * (3. - 2.*uv);
	
	return mix(a, b, t.x) +
		(c - a)* t.y * (1.0 - t.x) +
		(d - b) * t.y * t.x;
}

vec2 noiseNewUV(vec2 cr, vec2 uv){
	return smoothstep2D(cr, uv) * ( vec2(sin(TIME), cos(TIME)) * 2.);
}

float noise(vec2 cr, vec2 uv) {
    vec2 u = uv*uv*(3.0-2.0*uv);

    return mix( mix( dot( random2D(cr + vec2(0.0,0.0) ), uv - vec2(0.0,0.0) ),
                     dot( random2D(cr + vec2(1.0,0.0) ), uv - vec2(1.0,0.0) ), u.x),
                mix( dot( random2D(cr + vec2(0.0,1.0) ), uv - vec2(0.0,1.0) ),
                     dot( random2D(cr + vec2(1.0,1.0) ), uv - vec2(1.0,1.0) ), u.x), u.y);
	// also [-1,1)
}

void fragment() {
    vec3 c3 = vec3(0);
	
	vec2 uv = fract(UV*n);
	vec2 cr = floor(UV*n);
	
	vec2 UV2 = UV*n + noiseNewUV(cr, uv);
	uv = fract(UV2);
	cr = floor(UV2);
	
	
    c3 = vec3( noise(cr, uv)*.5+.5 ); // [-1,1) -> [0,1)
//	c3 = vec3(
//		smoothstep(.1, .15, fract((noise(cr, uv)*.5+.5)*22.))
//	);
	
    COLOR = vec4(c3,1.0);
}
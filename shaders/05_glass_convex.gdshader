shader_type canvas_item;

// We follow the notation convention of https://phys.libretexts.org/Bookshelves/University_Physics/Physics_(Boundless)/24%3A_Geometric_Optics/24.3%3A_Lenses
// see The Lensmakers equation section
uniform sampler2D screenTexture : hint_screen_texture;
uniform float n : hint_range(1.0, 2.0) = 1.4;//refractive index
// all length in the unit of spherical lens diameter

uniform float d : hint_range(0.001, 1.0) = 0.3; // R - thickness of lens
uniform float dist : hint_range(0.0, 0.5) = 0.02; // distance between screenTexture and midpt of lens

uniform vec3 tintSubtract = vec3(0.12, 0.03, 0.01);
uniform float tintStrength = 5.0;
// we approximate the light exiting from the lens and entering eyes to be exactly along z

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float r = length(uv);
	// (0) a circle lens, instead of square
	if(r > 0.499){
		COLOR = vec4(0.0);
	}else{
		float R = 0.5 * ((0.5*0.5) / d + d);
		// (1) refraction at p1
		float theta = asin(r / R);
		float theta2 = asin(1.0/n * r/R);
		vec3 n1 = vec3(0,0,1.0) * cos(theta) // outward pointing unit normal vector at p1
			+ vec3(1.0,0,0) * sin(theta) * uv.x / R
			+ vec3(0,1.0,0) * sin(theta) * uv.y / R;
		vec3 p1 = (dist - R + d) * vec3(0,0,1) + R * n1;
		// (1.5) q2
		float w1 = 1.0 / n;
		float w2 = cos(theta2) - w1 * cos(theta);
		vec3 q2 = normalize(w1 * vec3(0,0,1.0) + w2 * n1); // vector pointing towards p1 from p2
		// (2) refraction at p2
		float traversedDepth = d - R * (1.0 - cos(theta));
		vec3 p2 = p1 - q2 * traversedDepth / q2.z;
		float theta2a = theta - theta2; // angle between q2 and n2
		float theta3 = asin(n * sin(theta2a));
		vec3 n2 = vec3(0,0,-1);
		float w1a = n;
		float w2a = w1a * cos(theta2a) - cos(theta3);
		vec3 q3 = normalize(w1a * q2 + w2a * n2);
		// (3) to the UV
		vec3 p3 = p2 - q3 * dist / q3.z;

		//COLOR = texture(screenTexture, SCREEN_UV + (p2.xy - p1.xy));
		COLOR = texture(screenTexture, SCREEN_UV + (p3.xy - p1.xy)
			* vec2(0.6, 1.0)); // compensate viewport/screen ratio
		// (4) tint
		COLOR -= vec4(tintSubtract, 0) * length(p2 - p1) * tintStrength;
	}
}

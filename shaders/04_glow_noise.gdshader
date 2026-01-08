shader_type canvas_item;

uniform sampler2D gradient;
uniform sampler2D noise;

// in real use-case can set by GDScript
uniform vec2 top_left;
uniform vec2 size;
uniform float swizzling_omega;

void fragment() {
	// text glyph defines thhe uniform UV differently
	// (1) gradeint and noise
	vec2 r_eff = (SCREEN_UV - top_left) / size;
	vec4 gradientColor = texture(gradient, vec2(r_eff.y)); // can use a color ramp instead
	vec4 noiseColor = (texture(noise, SCREEN_UV) - vec4(.5, .5, .5, 1.0))
		/ 2.2;
	vec4 ownColor = texture(TEXTURE, UV);
	COLOR = gradientColor * ownColor + noiseColor;
	// (2) swizzling
	float exchangeRatio = sin(swizzling_omega * TIME * 0.5);
	exchangeRatio *= exchangeRatio;
	COLOR = COLOR.rgba * (1.0 - exchangeRatio)
		+ COLOR.gbra * (exchangeRatio);
}

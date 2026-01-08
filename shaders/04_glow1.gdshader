shader_type canvas_item;

uniform sampler2D gradient;
uniform sampler2D noise;

// in real use-case can set by GDScript
uniform vec2 top_left; 
uniform vec2 size;

void fragment() {
	// text glyph defines thhe uniform UV differently
	vec2 r_eff = (SCREEN_UV - top_left) / size;
	vec4 gradientColor = texture(gradient, vec2(r_eff.y)); // can use a color ramp instead
	vec4 noiseColor = (texture(noise, SCREEN_UV) - vec4(.5, .5, .5, 1.0))
		/ 3.0;
	vec4 ownColor = texture(TEXTURE, UV);
	COLOR = gradientColor * ownColor + noiseColor;
}

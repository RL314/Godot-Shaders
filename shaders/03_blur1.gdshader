shader_type canvas_item;

const float lumMax = 0.6;
uniform float lod : hint_range(0.0, 10.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	// brighter area less blurred, dimmer are more blurred
	vec4 textureColor = texture(screen_texture, SCREEN_UV);
	vec4 blurredColor = textureLod(screen_texture, SCREEN_UV, lod);
	float lum = clamp(
		(textureColor.r + textureColor.g + textureColor.b) / 3.0 / lumMax,
		0.0, 1.0
	);
	COLOR = mix(blurredColor, textureColor, lum * lum);
}

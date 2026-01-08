shader_type canvas_item;

uniform sampler2D gradient;

void fragment() {
	// (1) calculate brightness / luminance / some relevant value
	vec4 textureColor = texture(TEXTURE, UV);
	float minChannel = min(textureColor.r, min(textureColor.g, textureColor.b));
	float maxChannel = max(textureColor.r, max(textureColor.g, textureColor.b));
	float lum = (minChannel + maxChannel) * 0.5;
	//float lum = (textureColor.r + textureColor.g + textureColor.b) / 3.0;

	COLOR = texture(gradient, vec2(lum));
}

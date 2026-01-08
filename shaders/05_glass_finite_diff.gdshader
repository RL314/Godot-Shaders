shader_type canvas_item;

// is spherical

uniform sampler2D screenTexture : hint_screen_texture;
const float a = 2.0;
const float b = 0.2;

void fragment() {
	float thickness = texture(TEXTURE, UV).a; // roughtly

	float uv_dx = dFdxFine(thickness); // <- really blurry, try analytical sln
	float uv_dy = dFdyFine(thickness);
	vec2 uv = SCREEN_UV + a * vec2(uv_dx, uv_dy);
	COLOR = texture(screenTexture, uv);
	COLOR.r += sqrt(thickness) * b;
}

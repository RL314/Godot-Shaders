shader_type canvas_item;

const float omega = 3.0;
const float k = 15.0;
const float a = 0.003; // amplitude

void fragment() {
	vec2 wiggleUV = UV;
	wiggleUV.x += a * sin(omega * TIME + k * UV.y);
	COLOR = texture(TEXTURE, wiggleUV);
}

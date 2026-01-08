shader_type canvas_item;

const float period = 80.0;

void fragment() {
	float a = mod(VERTEX.x, period) / period;
	float b = mod(VERTEX.y, period) / period;
	COLOR = vec4(vec3(tanh(a+b)), 1);
}

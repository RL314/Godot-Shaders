shader_type canvas_item;

bool isOccupied(vec4 c){
	return c.z > 0.01 || c.w > 0.01;
}

void fragment() {
	if(isOccupied(texture(TEXTURE, UV))){
		COLOR = vec4(0,.2,.8,1);
	}else{
		COLOR = vec4(0);
	}
}


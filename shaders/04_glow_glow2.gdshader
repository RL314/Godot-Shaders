shader_type canvas_item;

// here we are trying to
// (1) select a rectangle inside the texture to display
// (2) make the border of the selected rectangle repeats itself outwards, for a stronger glow

// some observations
// (1) Seemingly the UV passed to shaders is subject to the TextureRect properties
//     (expand_mode, sretch_mode etc.)
//    and Control.clip-contents
// (2) VERTEX seems less used

uniform vec2 srcCentre = vec2(0.26, 0.6);
uniform vec2 halfLength = vec2(0.0391, 0.063);

void vertec(){

}

void fragment(){
	//vec2 uv = UV + srcCentre - halfLength;
	//uv = clamp(uv, )
	//vec4 textureColor = texture(TEXTURE, )
	//vec4 croppedTexture = texture(TEXTURE, )
}

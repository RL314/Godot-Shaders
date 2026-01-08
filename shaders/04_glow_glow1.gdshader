shader_type canvas_item;

uniform float lod = 2.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap_anisotropic;

void fragment() {
	vec4 unblurredTexture = texture(screen_texture, SCREEN_UV);
	vec4 blurredTexture = textureLod(screen_texture, SCREEN_UV, lod);
	// attempting to use two layers (failed)
//	assume unblurredTexture alpha = 0 or 1
//	if(unblurredTexture.a > 0.01){
//		COLOR = unblurredTexture;
//	}else{ // <- !! this takes the color value of the background and is no longer transparent
//		COLOR = vec4(blurredTexture.rgb, 1.0);
//	}
	COLOR = blurredTexture;

}

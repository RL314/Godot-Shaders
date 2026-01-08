shader_type canvas_item;

const vec2 center = vec2(0.4, 0.4);
const float r0 = 0.2;
const float omega = 1.1;
const vec2 screenSize = vec2(1000.0, 600.0);
// seems hard-coded, but in reality screenSize and these all are set/calc from GDScript
const vec2 screenSizeShortestSide = vec2(600.0, 600.0); 
const vec2 screenSizeRatio = vec2(10./6., 1.);

void fragment() {
	float radius = cos(TIME * omega);
	radius *= radius * r0;
	
	// FRAGCOORD is changed by window resizing and viewport w-h scale and recentering the Godot preview
	// screen space
	if(length(FRAGCOORD.xy * SCREEN_PIXEL_SIZE * screenSizeRatio - center) < radius){
		COLOR = vec4(0., 0., 0., 0.);
	}
	
	// SCREEN_UV is changed by viewport w-h ratio and recentering the Godot preview
	// screen space normalized
//	if(length(SCREEN_UV * screenSizeRatio - center) < radius){
//		COLOR = vec4(0., 0., 0., 0.);
//	}
	
	// VERTEX is changed by window resizing and viewport w-h scale and recentering the Godot preview
//	if(length(VERTEX * SCREEN_PIXEL_SIZE * screenSizeRatio - center) < radius){
//		COLOR = vec4(0., 0., 0., 0.);
//	}	
	
	// POINT_COORD ???	
	
}

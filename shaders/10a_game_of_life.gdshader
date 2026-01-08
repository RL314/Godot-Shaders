shader_type canvas_item;

// time-constant
uniform vec2 size;
uniform sampler2D initialTexture;
// time-variant
uniform int iFrame;
uniform sampler2D lastFrame;

int isLive(sampler2D grid, ivec2 xyInt){
	return int(texelFetch(grid, xyInt, 0).r > .8);
}

vec4 testInitial(ivec2 xyInt){
	float c = float(isLive(initialTexture, xyInt));
	return vec4(c, c, c, 1.);
}

void fragment() {
	ivec2 xyInt = ivec2(UV * size);

	if(iFrame < 5){
		COLOR = testInitial(xyInt);
	}else{
		int liveNeighbors = 0;
		// periodic boundary
		int x0 = (xyInt.x-1+int(size.x)) % int(size.x);
		int x1 = xyInt.x;
		int x2 = (xyInt.x+1) % int(size.x);
		int y0 = (xyInt.y-1+int(size.y)) % int(size.y);
		int y1 = xyInt.y;
		int y2 = (xyInt.y+1) % int(size.y);
		liveNeighbors += (
			isLive(lastFrame, ivec2( x1, y2)) +
			isLive(lastFrame, ivec2( x2, y2)) +
			isLive(lastFrame, ivec2( x2, y1)) +
			isLive(lastFrame, ivec2( x2, y0)) +
			isLive(lastFrame, ivec2( x1, y0)) +
			isLive(lastFrame, ivec2( x0, y0)) +
			isLive(lastFrame, ivec2( x0, y1)) +
			isLive(lastFrame, ivec2( x0, y2))
		);

		// (2) apply rules
		if(liveNeighbors < 2){
			COLOR = vec4(0,0,0,1); // (2a) underpopulation
		}else if(liveNeighbors > 3){
			COLOR = vec4(0,0,0,1); // (2b) overpopulation
		}else if(liveNeighbors == 3){
			COLOR = vec4(1);
		}else{
			COLOR = vec4(float(isLive(lastFrame, xyInt) == 1));
		}
	}
}

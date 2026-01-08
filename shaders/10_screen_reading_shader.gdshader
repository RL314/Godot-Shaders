shader_type canvas_item;

// hint_screen_texture reads what is drawn in the same viewport before itself is drawn.
// Try reordering the scene tree or changing the z_index of nodes. 
// hint_screen_texture per se does not let you feed the preious frame to the next. 

// Also beware that the material previw in the inspector does not draw anything 
// computed from hint_screen_texture. 

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV+vec2(.1,.0), 0.0).rgb;

    c.rgb = mix(vec3(0.0), c.rgb, brightness);
    c.rgb = mix(vec3(0.5), c.rgb, contrast);
    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);

    COLOR.rgb = c;
}
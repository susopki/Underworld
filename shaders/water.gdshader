// Cheap optimized water surface: vertex ripple + scrolling colour bands.
// No texture samples, no screen reads — one shared material, shadows off.
shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx, depth_draw_opaque;

uniform vec3 deep_color : source_color = vec3(0.02, 0.16, 0.24);
uniform vec3 shallow_color : source_color = vec3(0.10, 0.42, 0.50);
uniform float wave_height = 0.018;
uniform float wave_speed = 0.6;
uniform float surface_alpha : hint_range(0.0, 1.0) = 0.8;

void vertex() {
	float w = sin(VERTEX.x * 1.7 + TIME * wave_speed)
		* cos(VERTEX.z * 1.5 + TIME * wave_speed * 0.8);
	VERTEX.y += w * wave_height;
}

void fragment() {
	float ripple = sin((UV.x + TIME * 0.03) * 38.0)
		* sin((UV.y - TIME * 0.025) * 34.0);
	ALBEDO = mix(deep_color, shallow_color, 0.5 + 0.5 * ripple);
	ROUGHNESS = 0.07;
	METALLIC = 0.0;
	SPECULAR = 0.55;
	ALPHA = surface_alpha;
}

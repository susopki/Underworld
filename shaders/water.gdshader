// Calm, clearly-translucent dark water. No wave displacement, no fresnel-opaque
// (which made the surface read as a solid slab). Cheap: no textures/screen reads.
shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

uniform vec3 water_color : source_color = vec3(0.04, 0.16, 0.20);
uniform float surface_alpha : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	// Faint slow shimmer so it isn't dead-flat — not waves.
	float shimmer = sin(UV.x * 8.0 + TIME * 0.4) * sin(UV.y * 7.0 - TIME * 0.3) * 0.02;
	ALBEDO = water_color + vec3(shimmer);
	ROUGHNESS = 0.12;
	METALLIC = 0.0;
	SPECULAR = 0.4;
	ALPHA = surface_alpha;
}

// Optimized water: animated wave normals + fresnel transparency. No textures,
// no screen reads. One shared material, shadows off — cheap but reads as water.
shader_type spatial;
render_mode cull_back, depth_draw_opaque, specular_schlick_ggx;

uniform vec3 deep_color : source_color = vec3(0.03, 0.13, 0.18);
uniform vec3 shallow_color : source_color = vec3(0.13, 0.42, 0.48);
uniform float wave_speed = 0.8;
uniform float wave_height = 0.025;
uniform float normal_strength = 0.7;

float wave(vec2 p, float t) {
	return sin(p.x * 0.8 + t)
		+ sin(p.y * 1.1 + t * 1.3)
		+ sin((p.x + p.y) * 0.6 - t * 0.7);
}

void vertex() {
	float t = TIME * wave_speed;
	VERTEX.y += wave(VERTEX.xz, t) * wave_height;
}

void fragment() {
	float t = TIME * wave_speed;
	vec2 p = UV * 26.0;
	float e = 0.45;
	float h  = wave(p, t);
	float hx = wave(p + vec2(e, 0.0), t);
	float hz = wave(p + vec2(0.0, e), t);
	// Tangent-space normal from the wave gradient.
	NORMAL_MAP = normalize(vec3((h - hx) * normal_strength, (h - hz) * normal_strength, 1.0)) * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 1.0;

	float fres = pow(clamp(1.0 - dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
	ALBEDO = mix(deep_color, shallow_color, clamp(0.45 + 0.18 * h, 0.0, 1.0));
	ROUGHNESS = 0.04;
	METALLIC = 0.0;
	SPECULAR = 0.65;
	RIM = 0.25;
	ALPHA = mix(0.74, 0.97, fres);
}

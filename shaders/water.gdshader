// Animated water with moving waves, screen refraction, fresnel and live
// speculars. Forward+ only (uses the screen texture). Looks "alive" when you
// walk through it; not a flat slab.
shader_type spatial;
render_mode cull_back, specular_schlick_ggx, depth_prepass_alpha;

uniform vec3 shallow_color : source_color = vec3(0.10, 0.36, 0.42);
uniform vec3 deep_color : source_color = vec3(0.01, 0.07, 0.11);
uniform float wave_amp = 0.06;
uniform float wave_speed = 1.0;
uniform float refraction = 0.045;
uniform float surface_alpha : hint_range(0.0, 1.0) = 0.86;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;

float wave(vec2 p, float t) {
	return sin(p.x * 0.7 + t) * 0.6
		+ sin(p.y * 0.9 + t * 1.2) * 0.5
		+ sin((p.x + p.y) * 0.5 - t * 0.8) * 0.4
		+ sin((p.x - p.y) * 1.3 + t * 1.7) * 0.2;
}

void vertex() {
	float t = TIME * wave_speed;
	VERTEX.y += wave(VERTEX.xz, t) * wave_amp;
}

void fragment() {
	float t = TIME * wave_speed;
	vec2 p = (UV - 0.5) * 22.0;
	float e = 0.4;
	float h = wave(p, t);
	float hx = wave(p + vec2(e, 0.0), t);
	float hz = wave(p + vec2(0.0, e), t);
	// Tangent-space normal from the wave gradient (PlaneMesh supplies tangents).
	vec3 n = normalize(vec3((h - hx), (h - hz), 1.2));
	NORMAL_MAP = n * 0.5 + 0.5;
	NORMAL_MAP_DEPTH = 1.0;

	// Screen-space refraction: distort what's seen through the water by the waves.
	vec2 ref_uv = SCREEN_UV + n.xy * refraction;
	vec3 refracted = texture(screen_tex, ref_uv).rgb;

	float fres = pow(clamp(1.0 - dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 4.0);
	vec3 tint = mix(deep_color, shallow_color, clamp(0.5 + 0.25 * h, 0.0, 1.0));
	// Blend the refracted scene with the water tint; more tint at grazing angles.
	ALBEDO = mix(refracted * (shallow_color * 2.2), tint, mix(0.35, 0.85, fres));
	ROUGHNESS = 0.03;
	METALLIC = 0.0;
	SPECULAR = 0.75;
	RIM = 0.2;
	ALPHA = mix(surface_alpha * 0.7, 1.0, fres);
}

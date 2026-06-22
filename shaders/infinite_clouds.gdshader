shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec3 sky_color : source_color = vec3(0.42, 0.48, 0.55);
uniform vec3 cloud_color : source_color = vec3(0.92, 0.92, 0.88);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0)), f.x), f.y);
}

void fragment() {
	vec2 p = UV * vec2(5.0, 3.0) + vec2(TIME * 0.025, TIME * 0.006);
	float n = noise(p) * 0.58 + noise(p * 2.1) * 0.28 + noise(p * 4.3) * 0.14;
	float cloud = smoothstep(0.43, 0.72, n + (1.0 - UV.y) * 0.16);
	ALBEDO = mix(sky_color, cloud_color, cloud);
	EMISSION = ALBEDO * (0.65 + cloud * 0.7);
	ROUGHNESS = 1.0;
}


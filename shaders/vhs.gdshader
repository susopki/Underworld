shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 2.0) = 0.55;
uniform float anomaly : hint_range(0.0, 1.0) = 0.0;
uniform float breathing_noise : hint_range(0.0, 1.0) = 0.0;
uniform float grain_amount : hint_range(0.0, 0.2) = 0.055;
uniform float chromatic : hint_range(0.0, 0.01) = 0.002;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME;
	float tracking = sin(t * 0.42) * 0.5 + 0.5;
	float band = sin(uv.y * 18.0 + t * 1.7) * 0.0007;
	band += sin(uv.y * 260.0 + t * 9.0) * 0.00018 * (0.5 + anomaly);
	float tear = step(0.985, hash(vec2(floor(t * 5.0), floor(uv.y * 30.0))));
	float head_switch = smoothstep(0.89, 0.98, uv.y) * sin(t * 42.0 + uv.y * 80.0);
	uv.x += band * intensity + tear * sin(t * 31.0) * (0.012 + anomaly * 0.025);
	uv.x += head_switch * (0.002 + anomaly * 0.011);
	uv.x += sin(uv.y * 90.0 + t * 2.2) * anomaly * 0.0028;
	uv.y += sin(uv.x * 34.0 + t * 0.8) * anomaly * 0.0012;
	float ca = chromatic * intensity + anomaly * 0.004;
	float r = texture(screen_texture, uv + vec2(ca, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(ca, 0.0)).b;
	vec3 col = vec3(r, g, b);
	float grain = hash(SCREEN_UV * vec2(973.0, 541.0) + fract(t) * 91.0) - 0.5;
	float block_noise = hash(floor(SCREEN_UV * vec2(96.0, 54.0)) + floor(t * 8.0));
	col += grain * grain_amount * intensity * (1.0 + anomaly * 1.6);
	col += (block_noise - 0.5) * anomaly * 0.065;
	col *= 0.92 + 0.08 * sin(SCREEN_UV.y * 720.0);
	col *= 0.98 + 0.05 * sin(SCREEN_UV.y * 13.0 + t * 1.4 + breathing_noise * 2.0);
	float vignette = smoothstep(0.85, 0.22, length(SCREEN_UV - 0.5));
	col *= mix(0.50 - anomaly * 0.18, 1.0, vignette);
	col = mix(col, vec3(dot(col, vec3(0.28, 0.62, 0.1))) * vec3(1.08, 1.02, 0.82), 0.16 + anomaly * 0.24);
	col.r += tracking * anomaly * 0.04;
	col.b -= anomaly * 0.035;
	COLOR = vec4(col, 1.0);
}

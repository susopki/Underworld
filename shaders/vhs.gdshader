shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 2.0) = 0.55;
uniform float anomaly : hint_range(0.0, 1.0) = 0.0;
uniform float grain_amount : hint_range(0.0, 0.2) = 0.055;
uniform float chromatic : hint_range(0.0, 0.01) = 0.002;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float t = TIME;
	float band = sin(uv.y * 18.0 + t * 1.7) * 0.0007;
	float tear = step(0.985, hash(vec2(floor(t * 5.0), floor(uv.y * 30.0))));
	uv.x += band * intensity + tear * sin(t * 31.0) * (0.012 + anomaly * 0.025);
	uv.x += sin(uv.y * 90.0 + t * 2.2) * anomaly * 0.0018;
	float ca = chromatic * intensity + anomaly * 0.004;
	float r = texture(screen_texture, uv + vec2(ca, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(ca, 0.0)).b;
	vec3 col = vec3(r, g, b);
	float grain = hash(SCREEN_UV * vec2(973.0, 541.0) + fract(t) * 91.0) - 0.5;
	col += grain * grain_amount * intensity;
	col *= 0.94 + 0.06 * sin(SCREEN_UV.y * 720.0);
	float vignette = smoothstep(0.85, 0.22, length(SCREEN_UV - 0.5));
	col *= mix(0.64, 1.0, vignette);
	col = mix(col, vec3(dot(col, vec3(0.28, 0.62, 0.1))) * vec3(1.08, 1.02, 0.82), 0.12);
	COLOR = vec4(col, 1.0);
}


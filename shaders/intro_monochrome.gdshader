shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float fade : hint_range(0.0, 1.0) = 0.0;
uniform float proximity : hint_range(0.0, 1.0) = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.13, 289.71))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	float block_y = floor(uv.y * 28.0);
	float time_block = floor(TIME * (7.0 + proximity * 24.0));
	float corrupt = step(0.84 - proximity * 0.38, hash(vec2(block_y, time_block)));
	float horizontal_tear = (hash(vec2(block_y + 9.0, time_block)) - 0.5) * corrupt * proximity * 0.16;
	uv.x += horizontal_tear;
	uv.y += sin(uv.x * 19.0 + TIME * 8.0) * proximity * proximity * 0.012;
	uv.y = fract(uv.y + step(0.965 - proximity * 0.15, hash(vec2(time_block, 44.0))) * proximity * 0.18);
	float flicker = 0.94 + sin(TIME * 17.0) * 0.018;
	if (hash(vec2(floor(TIME * (5.0 + proximity * 20.0)), 2.0)) > 0.94 - proximity * 0.28) flicker *= 0.12 + hash(vec2(time_block, 7.0));
	float split = proximity * proximity * 0.018;
	float red = texture(screen_texture, uv + vec2(split, 0.0)).r;
	float green = texture(screen_texture, uv).g;
	float blue = texture(screen_texture, uv - vec2(split, 0.0)).b;
	vec3 src = vec3(red, green, blue);
	vec3 glow = textureLod(screen_texture, uv, 4.0).rgb;
	float gray = dot(src, vec3(0.299, 0.587, 0.114));
	float bloom = max(max(glow.r, glow.g), glow.b);
	vec3 color = vec3(gray + bloom * 0.38) * flicker;
	color = smoothstep(vec3(0.015), vec3(0.92), color);
	float vignette = smoothstep(0.78, 0.18, length(uv - 0.5));
	color *= mix(0.38, 1.0, vignette);
	color += (hash(uv * 830.0 + TIME) - 0.5) * 0.035;
	float scan = sin(uv.y * (620.0 + proximity * 480.0) + TIME * 35.0);
	color += scan * (0.018 + proximity * 0.085);
	if (hash(vec2(time_block, 81.0)) > 0.975 - proximity * 0.18) {
		color = mix(color, vec3(1.0) - color, 0.35 + proximity * 0.5);
	}
	COLOR = vec4(mix(color, vec3(0.0), fade), 1.0);
}

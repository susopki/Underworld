class_name AtmosphereManager
extends Node

@export var world_environment_path: NodePath
@export var vhs_rect_path: NodePath
var anomaly := 0.0
var _target_anomaly := 0.0
var _environment: Environment
var _zone := 0
var _breath := 0.0

func _ready() -> void:
	var world := get_node_or_null(world_environment_path) as WorldEnvironment
	if world:
		var env := Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.025, 0.022, 0.014)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.38, 0.34, 0.22)
		env.ambient_light_energy = 0.32
		env.fog_enabled = true
		env.fog_light_color = Color(0.31, 0.28, 0.18)
		env.fog_light_energy = 0.55
		env.fog_density = 0.038
		env.fog_height = 0.0
		env.fog_height_density = 0.14
		env.fog_sky_affect = 0.0
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		env.tonemap_exposure = 0.88
		env.tonemap_white = 1.0
		env.adjustment_enabled = true
		env.adjustment_brightness = 0.78
		env.adjustment_contrast = 1.28
		env.adjustment_saturation = 0.68
		env.glow_enabled = true
		env.glow_normalized = false
		env.glow_intensity = 0.55
		env.glow_strength = 0.85
		env.glow_bloom = 0.22
		env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
		world.environment = env
		_environment = env

func _process(delta: float) -> void:
	_breath += delta
	anomaly = move_toward(anomaly, _target_anomaly, delta * (0.9 if _target_anomaly > anomaly else 0.3))
	if anomaly >= _target_anomaly and _target_anomaly > 0.0:
		_target_anomaly = 0.0
	if _environment:
		var low_pulse := sin(_breath * 0.23 + float(_zone) * 0.9) * 0.5 + 0.5
		_environment.fog_density = lerpf(_environment.fog_density, _base_fog_density(_zone) + low_pulse * 0.006 + anomaly * 0.018, delta * 0.22)
		_environment.ambient_light_energy = lerpf(_environment.ambient_light_energy, 0.34 + low_pulse * 0.08, delta * 0.18)
	var rect := get_node_or_null(vhs_rect_path) as ColorRect
	if rect and rect.material:
		var shader_material := rect.material as ShaderMaterial
		shader_material.set_shader_parameter("anomaly", anomaly)
		shader_material.set_shader_parameter("breathing_noise", sin(_breath * 0.31) * 0.5 + 0.5)

func pulse_anomaly(strength := 0.8) -> void:
	_target_anomaly = maxf(_target_anomaly, strength)

func set_zone(zone_id: int) -> void:
	if not _environment:
		return
	_zone = posmod(zone_id, 7)
	var fog_colors := [
		Color(0.31, 0.28, 0.18),
		Color(0.18, 0.34, 0.36),
		Color(0.22, 0.15, 0.13),
		Color(0.10, 0.12, 0.105),
		Color(0.24, 0.215, 0.18),
		Color(0.11, 0.13, 0.15),
		Color(0.12, 0.22, 0.14),  # Floodlights: dense greenish fog
	]
	var ambient_colors := [
		Color(0.38, 0.34, 0.22),
		Color(0.25, 0.43, 0.45),
		Color(0.31, 0.22, 0.18),
		Color(0.18, 0.21, 0.18),
		Color(0.3, 0.27, 0.22),
		Color(0.16, 0.19, 0.22),
		Color(0.14, 0.26, 0.16),  # Floodlights: cold green ambience
	]
	var index := _zone
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_environment, "fog_light_color", fog_colors[index], 2.2)
	tween.tween_property(_environment, "ambient_light_color", ambient_colors[index], 2.2)
	tween.tween_property(_environment, "fog_density", _base_fog_density(index), 2.2)
	tween.tween_property(_environment, "adjustment_saturation", [0.68, 0.54, 0.48, 0.42, 0.58, 0.38, 0.52][index], 2.2)
	tween.tween_property(_environment, "adjustment_contrast", [1.22, 1.34, 1.28, 1.42, 1.18, 1.5, 1.38][index], 2.2)
	pulse_anomaly(0.72)

func fog_surge(strength := 1.0, duration := 5.0) -> void:
	if not _environment:
		return
	var original := _environment.fog_density
	var tween := create_tween()
	tween.tween_property(_environment, "fog_density", minf(0.13, original + 0.065 * strength), 0.65)
	tween.tween_interval(duration)
	tween.tween_property(_environment, "fog_density", original, 4.0)
	pulse_anomaly(0.35 * strength)

func _base_fog_density(zone_id: int) -> float:
	return [0.036, 0.045, 0.043, 0.05, 0.032, 0.055, 0.072][posmod(zone_id, 7)]

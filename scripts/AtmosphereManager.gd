class_name AtmosphereManager
extends Node

@export var world_environment_path: NodePath
@export var vhs_rect_path: NodePath
var anomaly := 0.0
var _target_anomaly := 0.0
var _environment: Environment

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
		env.fog_density = 0.032
		env.fog_height = 0.0
		env.fog_height_density = 0.08
		env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
		world.environment = env
		_environment = env

func _process(delta: float) -> void:
	anomaly = move_toward(anomaly, _target_anomaly, delta * (0.9 if _target_anomaly > anomaly else 0.3))
	if anomaly >= _target_anomaly and _target_anomaly > 0.0:
		_target_anomaly = 0.0
	var rect := get_node_or_null(vhs_rect_path) as ColorRect
	if rect and rect.material:
		(rect.material as ShaderMaterial).set_shader_parameter("anomaly", anomaly)

func pulse_anomaly(strength := 0.8) -> void:
	_target_anomaly = maxf(_target_anomaly, strength)

func set_zone(zone_id: int) -> void:
	if not _environment:
		return
	var fog_colors := [
		Color(0.31, 0.28, 0.18),
		Color(0.18, 0.34, 0.36),
		Color(0.22, 0.15, 0.13),
		Color(0.10, 0.12, 0.105),
		Color(0.24, 0.215, 0.18),
		Color(0.11, 0.13, 0.15)
	]
	var ambient_colors := [
		Color(0.38, 0.34, 0.22),
		Color(0.25, 0.43, 0.45),
		Color(0.31, 0.22, 0.18),
		Color(0.18, 0.21, 0.18),
		Color(0.3, 0.27, 0.22),
		Color(0.16, 0.19, 0.22)
	]
	var index := posmod(zone_id, 6)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_environment, "fog_light_color", fog_colors[index], 2.2)
	tween.tween_property(_environment, "ambient_light_color", ambient_colors[index], 2.2)
	tween.tween_property(_environment, "fog_density", [0.032, 0.045, 0.038, 0.055, 0.028, 0.062][index], 2.2)
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

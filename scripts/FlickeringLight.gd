class_name FlickeringLight
extends OmniLight3D

@export var base_energy := 2.4
@export var random_flicker := true
var forced_time := 0.0
var _next_glitch := 2.0

func _ready() -> void:
	light_energy = base_energy
	_next_glitch = randf_range(1.0, 8.0)

func _process(delta: float) -> void:
	_next_glitch -= delta
	forced_time = maxf(0.0, forced_time - delta)
	if forced_time > 0.0:
		visible = randf() > 0.38
		light_energy = base_energy * randf_range(0.15, 1.2)
	elif random_flicker and _next_glitch <= 0.0:
		visible = randf() > 0.12
		light_energy = base_energy * randf_range(0.65, 1.05)
		_next_glitch = randf_range(3.0, 14.0)
	else:
		visible = true
		light_energy = lerpf(light_energy, base_energy, delta * 5.0)

func scare_flicker(duration := 3.0) -> void:
	forced_time = duration


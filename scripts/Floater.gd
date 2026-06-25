class_name Floater
extends Node3D
## Gently bobs and drifts — used for debris floating on the Drowned Halls water.

var bob_amp := 0.05
var bob_speed := 1.0
var spin := 0.15
var _base_y := 0.0
var _phase := 0.0

func _ready() -> void:
	_base_y = position.y
	_phase = randf() * TAU
	bob_speed = randf_range(0.7, 1.3)
	spin = randf_range(-0.25, 0.25)

func _process(delta: float) -> void:
	_phase += delta * bob_speed
	position.y = _base_y + sin(_phase) * bob_amp
	rotation.y += delta * spin
	rotation.x = sin(_phase * 0.7) * 0.04
	rotation.z = cos(_phase * 0.9) * 0.04

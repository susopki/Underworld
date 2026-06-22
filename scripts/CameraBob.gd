class_name CameraBob
extends Camera3D

@export var bob_frequency := 1.65
@export var bob_height := 0.035
@export var bob_side := 0.024
var _time := 0.0
var _base_position: Vector3

func _ready() -> void:
	_base_position = position

func _process(delta: float) -> void:
	var player := get_parent().get_parent() as PlayerController
	var speed := player.horizontal_speed() if player else 0.0
	if speed > 0.12 and player.is_on_floor():
		_time += delta * bob_frequency * minf(speed, 3.0)
	var amount: float = clampf(speed / 2.35, 0.0, 1.0)
	var target := _base_position
	target.y += sin(_time * TAU) * bob_height * amount
	target.x += cos(_time * TAU * 0.5) * bob_side * amount
	# An almost imperceptible breathing sway remains when standing still.
	target.y += sin(Time.get_ticks_msec() * 0.0014) * 0.004
	position = position.lerp(target, minf(delta * 9.0, 1.0))

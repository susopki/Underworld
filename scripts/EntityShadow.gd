class_name EntityShadow
extends Node3D

@export var vanish_distance := 7.0
var target: Node3D
var life := 18.0

func _process(delta: float) -> void:
	life -= delta
	if not target or life <= 0.0:
		fade_out()
		return
	look_at(Vector3(target.global_position.x, global_position.y + 1.0, target.global_position.z), Vector3.UP)
	if global_position.distance_to(target.global_position) < vanish_distance:
		fade_out()

func fade_out() -> void:
	if is_queued_for_deletion():
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.02, 1.15, 0.02), 0.18)
	tween.tween_callback(queue_free)


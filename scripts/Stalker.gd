class_name Stalker
extends Node3D
## A tall, fully-black figure that appears behind the player after a knock.
## The moment the player turns to face it, it knocks them off their feet.

var target: Node3D
var _fired := false
var life := 9.0

func _ready() -> void:
	_build()

func _process(delta: float) -> void:
	life -= delta
	if not is_instance_valid(target):
		queue_free()
		return
	# Always face the player (it stares back).
	look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
	var to_me := global_position - target.global_position
	to_me.y = 0.0
	if to_me.length() < 0.1:
		return
	to_me = to_me.normalized()
	var fwd := -target.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	# Player turned to look at it → it lunges and knocks them down.
	if not _fired and fwd.dot(to_me) > 0.6:
		_fired = true
		if target.has_method("knock_down"):
			target.knock_down(10.0)
		var t := create_tween()
		t.tween_interval(0.45)
		t.tween_callback(queue_free)
	elif life <= 0.0 and not _fired:
		queue_free()

func _build() -> void:
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.002, 0.002, 0.004)
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tall, thin, slightly hunched humanoid ~2.7 m.
	_capsule(Vector3(0, 1.45, 0), Vector3(0.34, 1.5, 0.26), black)        # torso
	_capsule(Vector3(0, 2.5, 0), Vector3(0.22, 0.55, 0.2), black)         # neck/upper
	_sphere(Vector3(0, 2.78, 0.02), Vector3(0.26, 0.34, 0.24), black)     # head
	_capsule(Vector3(-0.3, 1.5, 0), Vector3(0.08, 1.7, 0.08), black, Vector3(0, 0, -0.16))  # arm L
	_capsule(Vector3(0.3, 1.45, 0), Vector3(0.08, 1.8, 0.08), black, Vector3(0, 0, 0.13))   # arm R
	_capsule(Vector3(-0.13, 0.5, 0), Vector3(0.1, 1.0, 0.1), black)       # leg L
	_capsule(Vector3(0.13, 0.5, 0), Vector3(0.1, 1.0, 0.1), black)        # leg R

func _capsule(pos: Vector3, size: Vector3, mat: Material, rot := Vector3.ZERO) -> void:
	var n := MeshInstance3D.new()
	var m := CapsuleMesh.new()
	m.radius = 0.5
	m.height = 1.0
	m.radial_segments = 8
	m.rings = 3
	m.material = mat
	n.mesh = m
	n.position = pos
	n.scale = size * 2.0
	n.rotation = rot
	add_child(n)

func _sphere(pos: Vector3, size: Vector3, mat: Material) -> void:
	var n := MeshInstance3D.new()
	var m := SphereMesh.new()
	m.radius = 0.5
	m.height = 1.0
	m.radial_segments = 8
	m.rings = 4
	m.material = mat
	n.mesh = m
	n.position = pos
	n.scale = size * 2.0
	add_child(n)

class_name BiomeEntity
extends Node3D

@export var biome := 0
var target: Node3D
var life := 20.0
var _built := false

func _ready() -> void:
	_build_entity()

func _process(delta: float) -> void:
	life -= delta
	if not target or life <= 0.0:
		_disappear()
		return
	var distance := global_position.distance_to(target.global_position)
	match biome:
		0: # Something crossing the office ceiling.
			position.x += sin(Time.get_ticks_msec() * 0.004) * delta * 0.25
		1: # Only a head above the still pool.
			position.y = 0.13 + sin(Time.get_ticks_msec() * 0.0018) * 0.035
		2: # Peeks out, then retracts behind a wall.
			rotation.y = sin(Time.get_ticks_msec() * 0.001) * 0.12
		3: # A tall shape advances only while far away.
			if distance > 12.0:
				global_position = global_position.move_toward(target.global_position, delta * 0.38)
		4: # Mall mannequins rotate only when the player looks away.
			look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		5: # Hanging stairwell shape sways without approaching.
			rotation.z = sin(Time.get_ticks_msec() * 0.0017) * 0.09
	if distance < [6.0, 5.0, 7.5, 9.0, 8.0, 7.0][biome]:
		_disappear()

func _build_entity() -> void:
	if _built:
		return
	_built = true
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.001, 0.001, 0.002)
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	match biome:
		0:
			_add_capsule(Vector3(0, 2.65, 0), Vector3(1.2, 0.18, 0.22), black)
			for x in [-0.8, -0.3, 0.3, 0.8]:
				_add_capsule(Vector3(x, 2.52, 0), Vector3(0.08, 0.38, 0.08), black, Vector3(0, 0, 0.65))
		1:
			_add_sphere(Vector3(0, 0.18, 0), Vector3(0.32, 0.43, 0.28), black)
			_add_box(Vector3(0, 0.015, 0), Vector3(0.7, 0.02, 2.8), black)
		2:
			_add_capsule(Vector3(0, 1.05, 0), Vector3(0.28, 0.95, 0.24), black)
			_add_sphere(Vector3(0.18, 2.0, 0), Vector3(0.25, 0.34, 0.24), black)
		3:
			_add_capsule(Vector3(0, 1.65, 0), Vector3(0.32, 1.55, 0.3), black)
			_add_sphere(Vector3(0.12, 3.3, 0), Vector3(0.3, 0.42, 0.26), black)
			_add_capsule(Vector3(-0.42, 1.7, 0), Vector3(0.1, 1.35, 0.1), black, Vector3(0, 0, -0.18))
			_add_capsule(Vector3(0.48, 1.65, 0), Vector3(0.1, 1.45, 0.1), black, Vector3(0, 0, 0.15))
		4:
			# Three low-poly mannequins stand too close together.
			for x in [-0.72, 0.0, 0.72]:
				_add_capsule(Vector3(x, 0.95, 0), Vector3(0.23, 0.88, 0.2), black)
				_add_sphere(Vector3(x, 1.92, 0), Vector3(0.2, 0.27, 0.19), black)
		5:
			_add_capsule(Vector3(0, 2.95, 0), Vector3(0.28, 1.25, 0.24), black, Vector3(0, 0, 3.14159))
			_add_sphere(Vector3(0, 1.62, 0), Vector3(0.26, 0.34, 0.23), black)
			_add_capsule(Vector3(0, 4.78, 0), Vector3(0.055, 0.72, 0.055), black)

func _add_box(pos: Vector3, size: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	add_child(node)

func _add_sphere(pos: Vector3, size: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	node.scale = size * 2.0
	add_child(node)

func _add_capsule(pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO) -> void:
	var node := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 8
	mesh.rings = 3
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	node.scale = size * 2.0
	node.rotation = rot
	add_child(node)

func _disappear() -> void:
	if is_queued_for_deletion():
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 1.3, 0.01), 0.16)
	tween.tween_callback(queue_free)

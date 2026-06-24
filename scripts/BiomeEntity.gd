class_name BiomeEntity
extends Node3D

@export var biome := 0
@export var entity_variant := 0
var target: Node3D
var life := 20.0
var _built := false
var _base_scale := Vector3.ONE

func _ready() -> void:
	_build_entity()

func _process(delta: float) -> void:
	life -= delta
	if not target or life <= 0.0:
		_disappear()
		return
	var distance := global_position.distance_to(target.global_position)
	var now := float(Time.get_ticks_msec()) * 0.001
	scale = _base_scale * (1.0 + sin(now * 9.0 + float(entity_variant)) * 0.018)
	if entity_variant == 1 or entity_variant == 7:
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
		if distance > 7.0:
			global_position = global_position.move_toward(target.global_position, delta * 0.7)
	elif entity_variant == 2 or entity_variant == 6:
		rotation.y += sin(now * 19.0) * delta * 1.8
	elif entity_variant == 3 or entity_variant == 5:
		position.y += sin(now * 8.0) * delta * 0.16
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
	var vanish_distance: float = [6.0, 5.0, 7.5, 9.0, 8.0, 7.0, 9.0][posmod(biome, 7)]
	if entity_variant == 1 or entity_variant == 6:
		vanish_distance += 2.2
	if distance < vanish_distance:
		_disappear()

func _build_entity() -> void:
	if _built:
		return
	_built = true
	_base_scale = Vector3.ONE
	var black := _shadow_material(Color(0.001, 0.001, 0.002))
	var wet_black := _shadow_material(Color(0.0, 0.006, 0.008))
	var eye := _emissive_material([Color(0.95, 0.05, 0.02), Color(0.12, 0.55, 0.95), Color(0.95, 0.8, 0.12)][posmod(biome + entity_variant, 3)], 1.8)
	if entity_variant >= 10:
		_build_mannequin_cluster_member(black, eye)
		return
	if entity_variant == 1:
		_build_tall_stare(black, eye)
		return
	if entity_variant == 2:
		_build_side_peeker(black, eye)
		return
	if entity_variant == 3 or entity_variant == 5:
		_build_ceiling_crawler(black, eye)
		return
	if entity_variant == 4:
		_build_flat_error(black, eye)
		return
	if entity_variant == 6:
		_build_close_wrong_face(black, eye)
		return
	if entity_variant == 7:
		_build_hollow_door_shape(black, eye)
		return
	match biome:
		0:
			_add_capsule(Vector3(0, 2.65, 0), Vector3(1.2, 0.18, 0.22), black)
			for x in [-0.8, -0.3, 0.3, 0.8]:
				_add_capsule(Vector3(x, 2.52, 0), Vector3(0.08, 0.38, 0.08), black, Vector3(0, 0, 0.65))
		1:
			_add_sphere(Vector3(0, 0.18, 0), Vector3(0.32, 0.43, 0.28), wet_black)
			_add_box(Vector3(0, 0.015, 0), Vector3(0.7, 0.02, 2.8), wet_black)
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
	_add_eye_pair(eye, 0.16, 1.92, 0.255)

func _build_tall_stare(black: Material, eye: Material) -> void:
	_base_scale = Vector3(1.0, 1.16, 0.78)
	_add_capsule(Vector3(0, 1.82, 0), Vector3(0.23, 1.82, 0.18), black)
	_add_sphere(Vector3(0, 3.72, 0), Vector3(0.24, 0.42, 0.16), black)
	_add_capsule(Vector3(-0.32, 1.9, 0), Vector3(0.055, 1.75, 0.055), black, Vector3(0, 0, -0.25))
	_add_capsule(Vector3(0.36, 1.8, 0), Vector3(0.055, 1.95, 0.055), black, Vector3(0, 0, 0.21))
	_add_eye_pair(eye, 0.09, 3.76, 0.18)

func _build_side_peeker(black: Material, eye: Material) -> void:
	_base_scale = Vector3(0.86, 1.0, 0.72)
	_add_box(Vector3(0.22, 1.1, 0), Vector3(0.22, 1.8, 0.16), black)
	_add_sphere(Vector3(0.38, 2.15, 0), Vector3(0.23, 0.34, 0.16), black)
	_add_box(Vector3(-0.08, 1.25, 0.0), Vector3(0.06, 2.4, 0.08), black)
	_add_eye_pair(eye, 0.055, 2.18, 0.17, 0.38)

func _build_ceiling_crawler(black: Material, eye: Material) -> void:
	_base_scale = Vector3(1.15, 0.8, 1.0)
	_add_capsule(Vector3(0, 2.85, 0), Vector3(0.88, 0.16, 0.18), black, Vector3(0, 0, PI * 0.5))
	for x in [-0.76, -0.34, 0.34, 0.76]:
		_add_capsule(Vector3(x, 2.63, 0), Vector3(0.045, 0.58, 0.045), black, Vector3(0.55, 0, 0))
	_add_sphere(Vector3(0.98, 2.86, 0), Vector3(0.2, 0.22, 0.16), black)
	_add_eye_pair(eye, 0.055, 2.9, 0.15, 1.0)

func _build_flat_error(black: Material, eye: Material) -> void:
	_base_scale = Vector3(1.25, 1.0, 0.6)
	_add_box(Vector3(0, 1.45, 0), Vector3(0.92, 2.75, 0.045), black)
	_add_box(Vector3(0, 2.95, 0), Vector3(0.55, 0.42, 0.05), black)
	_add_eye_pair(eye, 0.11, 3.02, 0.07)

func _build_close_wrong_face(black: Material, eye: Material) -> void:
	_base_scale = Vector3(0.72, 1.0, 0.72)
	_add_sphere(Vector3(0, 1.74, 0), Vector3(0.42, 0.58, 0.18), black)
	_add_box(Vector3(0, 1.05, 0), Vector3(0.2, 0.95, 0.12), black)
	_add_eye_pair(eye, 0.17, 1.82, 0.2)

func _build_hollow_door_shape(black: Material, eye: Material) -> void:
	_base_scale = Vector3(1.0, 1.12, 0.72)
	_add_box(Vector3(-0.43, 1.6, 0), Vector3(0.12, 3.0, 0.08), black)
	_add_box(Vector3(0.43, 1.6, 0), Vector3(0.12, 3.0, 0.08), black)
	_add_box(Vector3(0, 3.1, 0), Vector3(0.98, 0.12, 0.08), black)
	_add_sphere(Vector3(0, 1.75, 0), Vector3(0.18, 0.24, 0.12), black)
	_add_eye_pair(eye, 0.08, 1.78, 0.14)

func _build_mannequin_cluster_member(black: Material, eye: Material) -> void:
	_base_scale = Vector3(0.82 + float(entity_variant - 10) * 0.06, 1.0, 0.72)
	_add_capsule(Vector3(0, 0.92, 0), Vector3(0.2, 0.86, 0.16), black)
	_add_sphere(Vector3(0, 1.86, 0), Vector3(0.18, 0.27, 0.14), black)
	if entity_variant % 2 == 0:
		_add_eye_pair(eye, 0.055, 1.89, 0.14)

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

func _add_eye_pair(material: Material, spacing: float, y: float, z: float, x_offset := 0.0) -> void:
	_add_box(Vector3(x_offset - spacing, y, z), Vector3(0.055, 0.035, 0.025), material)
	_add_box(Vector3(x_offset + spacing, y, z), Vector3(0.055, 0.035, 0.025), material)

func _shadow_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := _shadow_material(color)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material

func _disappear() -> void:
	if is_queued_for_deletion():
		return
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 1.3, 0.01), 0.16)
	tween.tween_callback(queue_free)

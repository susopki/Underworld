class_name CorridorModule
extends Node3D

const WALL := preload("res://materials/wall.tres")
const FLOOR := preload("res://materials/floor.tres")
const CEILING := preload("res://materials/ceiling.tres")
@export var variant := 0
@export var zone_type := 0
@export var module_index := 0
@export var module_length := 12.0
@export var module_width := 6.0

func _ready() -> void:
	_build()

func _build() -> void:
	var palette := _zone_materials()
	var wall_mat: Material = palette[0]
	var floor_mat: Material = palette[1]
	var ceiling_mat: Material = palette[2]
	_add_box("Floor", Vector3(module_width, 0.18, module_length), Vector3(0, -0.09, -module_length * 0.5), floor_mat, true)
	_add_box("Ceiling", Vector3(module_width, 0.16, module_length), Vector3(0, 3.15, -module_length * 0.5), ceiling_mat, true)
	_add_box("LeftWall", Vector3(0.18, 3.2, module_length), Vector3(-module_width * 0.5, 1.55, -module_length * 0.5), wall_mat, true)
	_add_box("RightWall", Vector3(0.18, 3.2, module_length), Vector3(module_width * 0.5, 1.55, -module_length * 0.5), wall_mat, true)
	# Repeating asymmetry makes identical modules feel subtly wrong.
	if variant == 1:
		_add_box("Narrowing", Vector3(1.35, 3.0, 0.28), Vector3(-2.25, 1.5, -7.8), wall_mat, true)
	elif variant == 2:
		_add_box("ColumnA", Vector3(0.55, 3.1, 0.55), Vector3(-1.8, 1.55, -4.5), wall_mat, true)
		_add_box("ColumnB", Vector3(0.55, 3.1, 0.55), Vector3(1.8, 1.55, -7.5), wall_mat, true)
	elif variant == 3:
		_add_box("LowBeam", Vector3(module_width, 0.42, 0.42), Vector3(0, 2.72, -6.0), ceiling_mat, true)
	_add_zone_details(wall_mat, floor_mat)
	if module_index > 0 and module_index % 5 == 0:
		_add_transition_frame()
	_add_light(Vector3(0, 2.82, -3.0), variant != 3)
	_add_light(Vector3(0, 2.82, -9.0), true)

func _zone_materials() -> Array[Material]:
	match zone_type:
		1: # damp, overexposed poolrooms
			return [_material(Color(0.48, 0.66, 0.64)), _material(Color(0.12, 0.38, 0.43), 0.42), _material(Color(0.66, 0.73, 0.67))]
		2: # faded residential layer
			return [_material(Color(0.25, 0.18, 0.16)), _material(Color(0.12, 0.085, 0.07)), _material(Color(0.28, 0.25, 0.23))]
		3: # concrete underpass
			return [_material(Color(0.17, 0.18, 0.17)), _material(Color(0.07, 0.075, 0.07)), _material(Color(0.12, 0.13, 0.12))]
		_:
			return [WALL, FLOOR, CEILING]

func _material(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _add_zone_details(wall_mat: Material, floor_mat: Material) -> void:
	match zone_type:
		1:
			# A shallow reflective strip reads as motionless water.
			var water := _material(Color(0.18, 0.55, 0.62, 0.58), 0.12)
			water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_add_box("StillWater", Vector3(5.65, 0.035, module_length - 0.3), Vector3(0, 0.025, -module_length * 0.5), water, false)
		2:
			# Doors are only architectural shapes; none can be opened or collected from.
			var door := _material(Color(0.055, 0.035, 0.03), 1.0)
			_add_box("FalseDoorLeft", Vector3(0.08, 2.35, 1.25), Vector3(-2.88, 1.18, -4.0), door, false)
			_add_box("FalseDoorRight", Vector3(0.08, 2.35, 1.25), Vector3(2.88, 1.18, -8.2), door, false)
		3:
			var pipe := _material(Color(0.055, 0.06, 0.055), 0.45)
			_add_box("PipeLeft", Vector3(0.22, 0.22, module_length), Vector3(-2.55, 2.55, -module_length * 0.5), pipe, false)
			_add_box("PipeRight", Vector3(0.22, 0.22, module_length), Vector3(2.55, 2.25, -module_length * 0.5), pipe, false)

func _add_transition_frame() -> void:
	var dark := _material(Color(0.008, 0.008, 0.009), 0.72)
	_add_box("ThresholdLeft", Vector3(0.32, 3.15, 0.5), Vector3(-2.72, 1.55, -0.25), dark, false)
	_add_box("ThresholdRight", Vector3(0.32, 3.15, 0.5), Vector3(2.72, 1.55, -0.25), dark, false)
	_add_box("ThresholdTop", Vector3(5.7, 0.36, 0.5), Vector3(0, 2.98, -0.25), dark, false)

func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material, collision: bool) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	box.material = material
	mesh_instance.mesh = box
	mesh_instance.position = pos
	add_child(mesh_instance)
	if collision:
		var body := StaticBody3D.new()
		body.name = node_name + "Body"
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		body.position = pos
		body.add_child(shape_node)
		add_child(body)
	return mesh_instance

func _add_light(pos: Vector3, unstable: bool) -> void:
	var fixture := _add_box("FluorescentFixture", Vector3(1.8, 0.06, 0.34), pos + Vector3(0, 0.27, 0), CEILING, false)
	fixture.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var light := FlickeringLight.new()
	light.name = "FlickeringLight"
	light.position = pos
	light.omni_range = 8.5
	light.light_color = [Color(1.0, 0.83, 0.47), Color(0.62, 0.9, 0.95), Color(0.78, 0.63, 0.51), Color(0.56, 0.63, 0.57)][zone_type]
	light.shadow_enabled = true
	light.base_energy = 2.2
	light.random_flicker = unstable
	add_child(light)

class_name RoomModule
extends Node3D

const CLOUDS := preload("res://materials/cloud_window.tres")
@export var biome := 0
@export var openings := 0
@export var grid_coord := Vector2i.ZERO
@export var ceiling_rift := false
var room_size := 10.0
var room_height := 3.25

func _ready() -> void:
	_build_room()

func _build_room() -> void:
	room_height = [3.25, 4.1, 3.0, 3.65][biome]
	var palette := _palette()
	_add_box("Floor", Vector3(room_size, 0.18, room_size), Vector3(0, -0.09, 0), palette[1], true)
	_add_box("Ceiling", Vector3(room_size, 0.16, room_size), Vector3(0, room_height, 0), palette[2], true)
	_wall(0, bool(openings & 1), palette[0])
	_wall(1, bool(openings & 2), palette[0])
	_wall(2, bool(openings & 4), palette[0])
	_wall(3, bool(openings & 8), palette[0])
	_add_biome_geometry(palette)
	_add_room_light()
	if biome == 0 and ceiling_rift:
		_add_ceiling_rift()

func _wall(side: int, has_opening: bool, material: Material) -> void:
	var horizontal := side == 0 or side == 2
	var sign_value := -1.0 if side == 0 or side == 3 else 1.0
	var base := Vector3(0, room_height * 0.5, 0)
	if horizontal:
		base.z = sign_value * room_size * 0.5
	else:
		base.x = sign_value * room_size * 0.5
	if has_opening:
		for offset in [-3.15, 3.15]:
			var pos := base
			if horizontal: pos.x = offset
			else: pos.z = offset
			var size := Vector3(3.7, room_height, 0.18) if horizontal else Vector3(0.18, room_height, 3.7)
			_add_box("WallSegment", size, pos, material, true)
		var lintel_pos := base
		lintel_pos.y = room_height - 0.28
		var lintel_size := Vector3(2.6, 0.56, 0.2) if horizontal else Vector3(0.2, 0.56, 2.6)
		_add_box("Lintel", lintel_size, lintel_pos, material, true)
	else:
		var full_size := Vector3(room_size, room_height, 0.18) if horizontal else Vector3(0.18, room_height, room_size)
		_add_box("ClosedWall", full_size, base, material, true)
		if biome == 1:
			_add_cloud_window(side, base)

func _add_cloud_window(side: int, base: Vector3) -> void:
	var horizontal := side == 0 or side == 2
	var inward := Vector3.ZERO
	if side == 0: inward.z = 0.11
	elif side == 2: inward.z = -0.11
	elif side == 1: inward.x = -0.11
	else: inward.x = 0.11
	var window_pos := base + inward
	window_pos.y = 1.72
	var size := Vector3(5.8, 1.65, 0.045) if horizontal else Vector3(0.045, 1.65, 5.8)
	_add_box("InfiniteCloudWindow", size, window_pos, CLOUDS, false)
	var frame := _material(Color(0.045, 0.045, 0.04), 0.55)
	for y in [0.82, 2.61]:
		var bar_pos := window_pos
		bar_pos.y = y
		var bar_size := Vector3(6.05, 0.11, 0.12) if horizontal else Vector3(0.12, 0.11, 6.05)
		_add_box("WindowFrame", bar_size, bar_pos, frame, false)

func _add_biome_geometry(palette: Array[Material]) -> void:
	match biome:
		0:
			# Low office partitions create several sight lines per room.
			if (abs(grid_coord.x) + abs(grid_coord.y)) % 2 == 0:
				_add_box("CubicleA", Vector3(3.1, 1.35, 0.16), Vector3(-1.7, 0.67, 1.8), palette[0], true)
				_add_box("CubicleB", Vector3(0.16, 1.35, 3.0), Vector3(1.4, 0.67, -1.4), palette[0], true)
		1:
			var water := _material(Color(0.08, 0.45, 0.54, 0.62), 0.08)
			water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_add_box("PoolWater", Vector3(7.4, 0.04, 7.4), Vector3(0, 0.08, 0), water, false)
			for corner in [Vector3(-3.8, 1.8, -3.8), Vector3(3.8, 1.8, -3.8), Vector3(-3.8, 1.8, 3.8), Vector3(3.8, 1.8, 3.8)]:
				_add_box("PoolColumn", Vector3(0.52, 3.6, 0.52), corner, palette[0], true)
		2:
			var dark_wood := _material(Color(0.055, 0.028, 0.021), 0.9)
			_add_box("ApartmentDivider", Vector3(4.4, 2.55, 0.18), Vector3(-2.8, 1.27, 2.35), palette[0], true)
			_add_box("FalseApartmentDoor", Vector3(1.25, 2.35, 0.08), Vector3(-2.7, 1.17, 2.23), dark_wood, false)
		3:
			var metal := _material(Color(0.035, 0.045, 0.04), 0.38)
			_add_box("PipeA", Vector3(0.24, 0.24, 9.4), Vector3(-4.35, 2.75, 0), metal, false)
			_add_box("PipeB", Vector3(9.4, 0.2, 0.2), Vector3(0, 3.05, 4.25), metal, false)
			_add_box("ConcreteBeam", Vector3(10, 0.42, 0.48), Vector3(0, 2.92, 0), palette[2], true)

func _add_ceiling_rift() -> void:
	var black := _material(Color(0.0, 0.0, 0.0), 1.0)
	_add_box("CeilingRift", Vector3(3.8, 0.06, 2.15), Vector3(0.8, room_height - 0.11, -0.6), black, false)
	_add_box("BrokenSlabA", Vector3(1.8, 0.13, 0.65), Vector3(-0.65, room_height - 0.35, -0.3), _palette()[2], false)
	_add_box("BrokenSlabB", Vector3(0.8, 0.12, 1.5), Vector3(2.1, room_height - 0.48, -0.7), _palette()[2], false)
	var trigger := CeilingRift.new()
	trigger.name = "CeilingRiftTrigger"
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(7.0, 2.5, 7.0)
	collision.shape = shape
	trigger.position = Vector3(0, 1.25, 0)
	trigger.add_child(collision)
	add_child(trigger)

func _add_room_light() -> void:
	var light := FlickeringLight.new()
	light.name = "BiomeLight"
	light.add_to_group("liminal_lights")
	light.position = Vector3(0, room_height - 0.45, 0)
	light.omni_range = 9.5
	light.light_color = [Color(1.0, 0.83, 0.47), Color(0.55, 0.88, 0.96), Color(0.72, 0.52, 0.4), Color(0.42, 0.56, 0.47)][biome]
	light.base_energy = [2.2, 2.7, 1.35, 1.15][biome]
	light.shadow_enabled = true
	add_child(light)

func _palette() -> Array[Material]:
	match biome:
		1: return [_material(Color(0.48, 0.69, 0.67)), _material(Color(0.19, 0.48, 0.52), 0.3), _material(Color(0.73, 0.78, 0.71))]
		2: return [_material(Color(0.26, 0.15, 0.13)), _material(Color(0.09, 0.045, 0.035)), _material(Color(0.28, 0.23, 0.21))]
		3: return [_material(Color(0.15, 0.17, 0.16)), _material(Color(0.055, 0.06, 0.055)), _material(Color(0.11, 0.12, 0.11))]
		_: return [preload("res://materials/wall.tres"), preload("res://materials/floor.tres"), preload("res://materials/ceiling.tres")]

func _material(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _add_box(node_name: String, size: Vector3, pos: Vector3, material: Material, collision_enabled: bool) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	add_child(node)
	if collision_enabled:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.position = pos
		body.add_child(collision)
		add_child(body)
	return node

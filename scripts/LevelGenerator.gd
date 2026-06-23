class_name LevelGenerator
extends Node3D

const ROOM := preload("res://scenes/RoomModule.tscn")
const BIOME_COUNT := 6
@export var player_path: NodePath
@export var room_count := 42
@export var cell_size := 10.0

var current_level := 0
var generated_root: Node3D
var cells: Array[Vector2i] = []
var occupied := {}
var _rng := RandomNumberGenerator.new()
var _switching := false

func _ready() -> void:
	_rng.randomize()
	_generate_level(current_level)

func _generate_level(level_id: int) -> void:
	current_level = posmod(level_id, BIOME_COUNT)
	generated_root = Node3D.new()
	generated_root.name = ["YellowOffices", "DrownedHalls", "SilentApartments", "UnderpassTunnels", "DeadMall", "EndlessStairwell"][current_level]
	add_child(generated_root)
	_build_layout()
	var rift_cell := cells[_rng.randi_range(8, cells.size() - 1)] if current_level == 0 else Vector2i(999, 999)
	for cell in cells:
		var room := ROOM.instantiate() as RoomModule
		room.biome = current_level
		room.grid_coord = cell
		room.openings = _openings_for(cell)
		room.ceiling_rift = cell == rift_cell
		room.position = Vector3(cell.x * cell_size, 0, cell.y * cell_size)
		generated_root.add_child(room)
	_add_random_portals()

func _build_layout() -> void:
	cells.clear()
	occupied.clear()
	match current_level:
		0: _layout_office_maze()
		1: _layout_drowned_clusters()
		2: _layout_apartment_spine()
		3: _layout_tunnel_snake()
		4: _layout_mall_atrium()
		5: _layout_stairwell_spiral()

func _add_cell(cell: Vector2i) -> void:
	if not occupied.has(cell):
		occupied[cell] = true
		cells.append(cell)

func _layout_office_maze() -> void:
	var cursor := Vector2i.ZERO
	_add_cell(cursor)
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	while cells.size() < room_count:
		if _rng.randf() < 0.34:
			cursor = cells[_rng.randi_range(0, cells.size() - 1)]
		var candidate: Vector2i = cursor + directions[_rng.randi_range(0, 3)]
		if abs(candidate.x) > 6 or abs(candidate.y) > 6:
			continue
		cursor = candidate
		_add_cell(cursor)

func _layout_drowned_clusters() -> void:
	# One vast 7x5 pool hall with a connected upper gallery: exactly 42 cells.
	for x in range(-3, 4):
		for y in range(-2, 3):
			_add_cell(Vector2i(x, y))
	for x in range(-3, 4):
		_add_cell(Vector2i(x, 3))

func _layout_apartment_spine() -> void:
	# A long residential hallway with repeating side apartments.
	for x in range(-6, 7):
		_add_cell(Vector2i(x, 0))
		_add_cell(Vector2i(x, -1))
		_add_cell(Vector2i(x, 1))
	_add_cell(Vector2i(-6, -2))
	_add_cell(Vector2i(0, 2))
	_add_cell(Vector2i(6, -2))

func _layout_tunnel_snake() -> void:
	# Service tunnels are a long deterministic snake with dead maintenance cuts.
	# The old capped spiral could eventually walk the same loop forever.
	for x in range(0, 12):
		_add_cell(Vector2i(x, 0))
	_add_cell(Vector2i(11, 1))
	for x in range(11, -1, -1):
		_add_cell(Vector2i(x, 2))
	_add_cell(Vector2i(0, 3))
	for x in range(0, 12):
		_add_cell(Vector2i(x, 4))
	for branch in [Vector2i(3, -1), Vector2i(8, 1), Vector2i(6, 3), Vector2i(10, 5)]:
		_add_cell(branch)

func _layout_mall_atrium() -> void:
	# A rectangular atrium ring, cross-axis concourses, and shop bays.
	for x in range(-5, 6):
		_add_cell(Vector2i(x, -3))
		_add_cell(Vector2i(x, 3))
		_add_cell(Vector2i(x, 0))
	for y in range(-2, 3):
		_add_cell(Vector2i(-5, y))
		_add_cell(Vector2i(5, y))
	_add_cell(Vector2i(0, 1))

func _layout_stairwell_spiral() -> void:
	# Tight square spiral of landings; the room geometry supplies impossible flights.
	var cursor := Vector2i.ZERO
	_add_cell(cursor)
	var direction := Vector2i.RIGHT
	var leg_length := 1
	while cells.size() < room_count:
		for repeat in 2:
			for i in leg_length:
				cursor += direction
				_add_cell(cursor)
				if cells.size() >= room_count: return
			direction = Vector2i(-direction.y, direction.x)
		leg_length += 1

func _fill_connected(start: Vector2i) -> void:
	var cursor := start
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	while cells.size() < room_count:
		var candidate: Vector2i = cursor + directions[_rng.randi_range(0, 3)]
		if abs(candidate.x) <= 6 and abs(candidate.y) <= 6:
			cursor = candidate
			_add_cell(cursor)

func _trim_layout() -> void:
	while cells.size() > room_count:
		var removed: Vector2i = cells.pop_back()
		occupied.erase(removed)
	if cells.size() < room_count:
		_fill_connected(cells.back())

func _openings_for(cell: Vector2i) -> int:
	var mask := 0
	if occupied.has(cell + Vector2i.UP): mask |= 1
	if occupied.has(cell + Vector2i.RIGHT): mask |= 2
	if occupied.has(cell + Vector2i.DOWN): mask |= 4
	if occupied.has(cell + Vector2i.LEFT): mask |= 8
	return mask

func _add_random_portals() -> void:
	var candidates := cells.duplicate()
	candidates.sort_custom(func(a: Vector2i, b: Vector2i): return a.length_squared() > b.length_squared())
	# The only exit is deliberately buried in the farthest part of the maze.
	var portal_count := 1
	for i in portal_count:
		var cell: Vector2i = candidates[0]
		var target := posmod(current_level + _rng.randi_range(1, BIOME_COUNT - 1), BIOME_COUNT)
		_create_portal(Vector3(cell.x * cell_size, 0, cell.y * cell_size), target)

func _create_portal(where: Vector3, target: int) -> void:
	var portal := LevelPortal.new()
	portal.name = "DoorTo_%s" % ["Offices", "DrownedHalls", "Apartments", "Tunnels", "DeadMall", "Stairwell"][target]
	portal.target_level = target
	portal.position = where + Vector3(0, 0, 0)
	portal.portal_entered.connect(_request_level_switch)
	var trigger := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 2.8, 1.2)
	trigger.shape = shape
	trigger.position.y = 1.4
	portal.add_child(trigger)
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.0, 0.0, 0.0)
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_add_portal_box(portal, Vector3(2.0, 2.8, 0.12), Vector3(0, 1.4, 0), black)
	var frame := StandardMaterial3D.new()
	frame.albedo_color = [Color(0.48, 0.42, 0.18), Color(0.2, 0.7, 0.74), Color(0.42, 0.17, 0.12), Color(0.15, 0.24, 0.18), Color(0.42, 0.36, 0.31), Color(0.25, 0.29, 0.34)][target]
	frame.emission_enabled = true
	frame.emission = frame.albedo_color
	frame.emission_energy_multiplier = 2.2
	_add_portal_box(portal, Vector3(0.16, 3.05, 0.2), Vector3(-1.08, 1.5, 0), frame)
	_add_portal_box(portal, Vector3(0.16, 3.05, 0.2), Vector3(1.08, 1.5, 0), frame)
	_add_portal_box(portal, Vector3(2.3, 0.16, 0.2), Vector3(0, 3.0, 0), frame)
	generated_root.add_child(portal)

func _add_portal_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	parent.add_child(node)

func _request_level_switch(target: int) -> void:
	if _switching:
		return
	_switching = true
	var atmosphere := get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere:
		atmosphere.pulse_anomaly(1.0)
	get_tree().create_timer(0.32).timeout.connect(func(): _perform_switch(target))

func _perform_switch(target: int) -> void:
	if generated_root:
		generated_root.queue_free()
	_generate_level(target)
	var player := get_node_or_null(player_path) as PlayerController
	if player:
		player.global_position = Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
	var atmosphere := get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere:
		atmosphere.set_zone(current_level)
	var sounds := get_tree().get_first_node_in_group("sound_manager") as RandomSoundManager
	if sounds:
		sounds.set_biome(current_level)
	_switching = false

func get_entity_spawn_position(player: Node3D) -> Vector3:
	var distant: Array[Vector2i] = []
	for cell in cells:
		var point := Vector3(cell.x * cell_size, 0, cell.y * cell_size)
		if point.distance_to(player.global_position) > 16.0:
			distant.append(cell)
	var chosen: Vector2i = distant[_rng.randi_range(0, distant.size() - 1)] if not distant.is_empty() else cells.back()
	return Vector3(chosen.x * cell_size, 0, chosen.y * cell_size)

func extend_space(_amount := 3) -> void:
	# Fear event: the next doorway rebuilds the maze with a new topology.
	if _rng.randf() < 0.28:
		_request_level_switch(current_level)

func seal_space_behind(player: Node3D) -> void:
	var wall := StaticBody3D.new()
	wall.name = "WallThatWasNotThere"
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.7, 3.0, 0.18)
	mesh.material = preload("res://materials/wall.tres")
	mesh_node.mesh = mesh
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = mesh.size
	collision.shape = shape
	var wall_position := player.global_position + player.global_transform.basis.z * 2.2 + Vector3(0, 1.5, 0)
	var wall_rotation := player.global_rotation.y
	wall.add_child(mesh_node)
	wall.add_child(collision)
	generated_root.add_child(wall)
	wall.global_position = wall_position
	wall.global_rotation.y = wall_rotation

func flicker_all(duration := 3.0) -> void:
	for light in get_tree().get_nodes_in_group("liminal_lights"):
		if light is FlickeringLight:
			light.scare_flicker(duration)

func blackout_all(duration := 3.0) -> void:
	for light in get_tree().get_nodes_in_group("liminal_lights"):
		if light is FlickeringLight:
			light.blackout(duration)

func light_wave(player: Node3D) -> void:
	var lights := get_tree().get_nodes_in_group("liminal_lights")
	lights.sort_custom(func(a: Node3D, b: Node3D): return a.global_position.distance_to(player.global_position) < b.global_position.distance_to(player.global_position))
	for i in mini(10, lights.size()):
		var light := lights[i] as FlickeringLight
		get_tree().create_timer(i * 0.16).timeout.connect(func():
			if is_instance_valid(light): light.scare_flicker(1.1)
		)

func spawn_phantom_door(player: Node3D) -> void:
	var door := PhantomDoor.new()
	door.target = player
	generated_root.add_child(door)
	var spawn := get_entity_spawn_position(player)
	door.global_position = spawn
	door.look_at(Vector3(player.global_position.x, door.global_position.y, player.global_position.z), Vector3.UP)

class_name LevelGenerator
extends Node3D

const ROOM := preload("res://scenes/RoomModule.tscn")
const BIOME_COUNT := 7
const BIOME_ROOM_COUNTS := [42, 35, 46, 28, 52, 20, 60]
@export var player_path: NodePath
@export var cell_size := 10.0

var current_level := 0
var room_count := 42
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
	room_count = BIOME_ROOM_COUNTS[current_level]
	generated_root = Node3D.new()
	generated_root.name = ["YellowOffices", "DrownedHalls", "SilentApartments", "UnderpassTunnels", "DeadMall", "EndlessStairwell", "Floodlights"][current_level]
	add_child(generated_root)
	_build_layout()
	var rift_cell := cells[_rng.randi_range(8, cells.size() - 1)] if current_level == 0 else Vector2i(999, 999)
	var portal_cell := _portal_cell()
	var max_dist := _max_cell_dist()
	for cell in cells:
		var room := ROOM.instantiate() as RoomModule
		room.biome = current_level
		room.grid_coord = cell
		room.openings = _openings_for(cell)
		room.ceiling_rift = cell == rift_cell
		room.is_portal_room = cell == portal_cell
		room.depth_factor = float(cell.length()) / max(max_dist, 1.0)
		room.position = Vector3(cell.x * cell_size, 0, cell.y * cell_size)
		generated_root.add_child(room)
	_add_portal_at(portal_cell)
	if current_level == 6:
		_add_field_boundary()

## The open Floodlights pitch has no walls — ring it with invisible collision
## so the player can't walk off the field into the void.
func _add_field_boundary() -> void:
	var min_x := 9999
	var max_x := -9999
	var min_y := 9999
	var max_y := -9999
	for c in cells:
		min_x = mini(min_x, c.x)
		max_x = maxi(max_x, c.x)
		min_y = mini(min_y, c.y)
		max_y = maxi(max_y, c.y)
	var x0 := (float(min_x) - 0.5) * cell_size
	var x1 := (float(max_x) + 0.5) * cell_size
	var z0 := (float(min_y) - 0.5) * cell_size
	var z1 := (float(max_y) + 0.5) * cell_size
	var h := 6.0
	_add_invisible_wall(Vector3((x0 + x1) * 0.5, h * 0.5, z0), Vector3(x1 - x0, h, 0.4))
	_add_invisible_wall(Vector3((x0 + x1) * 0.5, h * 0.5, z1), Vector3(x1 - x0, h, 0.4))
	_add_invisible_wall(Vector3(x0, h * 0.5, (z0 + z1) * 0.5), Vector3(0.4, h, z1 - z0))
	_add_invisible_wall(Vector3(x1, h * 0.5, (z0 + z1) * 0.5), Vector3(0.4, h, z1 - z0))

func _add_invisible_wall(pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = "FieldBoundary"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	body.position = pos
	generated_root.add_child(body)

func _portal_cell() -> Vector2i:
	var candidates := cells.duplicate()
	candidates.sort_custom(func(a: Vector2i, b: Vector2i): return a.length_squared() > b.length_squared())
	return candidates[0]

func _add_portal_at(cell: Vector2i) -> void:
	var target := posmod(current_level + _rng.randi_range(1, BIOME_COUNT - 1), BIOME_COUNT)
	_create_portal(Vector3(cell.x * cell_size, 0, cell.y * cell_size), target)

func _max_cell_dist() -> float:
	var max_len := 0.0
	for cell in cells:
		max_len = maxf(max_len, float(cell.length()))
	return max_len

func _build_layout() -> void:
	cells.clear()
	occupied.clear()
	match current_level:
		0: _layout_office_maze()
		1: _layout_drowned_grid()
		2: _layout_apartment_spine()
		3: _layout_tunnel_snake()
		4: _layout_mall_atrium()
		5: _layout_stairwell_spiral()
		6: _layout_floodlights_pitch()

func _add_cell(cell: Vector2i) -> void:
	if not occupied.has(cell):
		occupied[cell] = true
		cells.append(cell)

# 42 rooms: organic random-walk maze — easy to get lost
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

# 35 rooms: clean 7×5 rectangular pool hall — open and oppressive
func _layout_drowned_grid() -> void:
	for x in range(-3, 4):
		for y in range(-2, 3):
			_add_cell(Vector2i(x, y))

# 46 rooms: long residential spine with side apartments — linear and claustrophobic
func _layout_apartment_spine() -> void:
	for x in range(-7, 8):
		_add_cell(Vector2i(x, 0))
		_add_cell(Vector2i(x, -1))
		_add_cell(Vector2i(x, 1))
	_add_cell(Vector2i(0, 2))

# 28 rooms: tight snake with dead-end maintenance cuts — forced progression
func _layout_tunnel_snake() -> void:
	for x in range(0, 10):
		_add_cell(Vector2i(x, 0))
	_add_cell(Vector2i(9, 1))
	for x in range(9, -1, -1):
		_add_cell(Vector2i(x, 2))
	_add_cell(Vector2i(0, 3))
	for branch in [Vector2i(2, -1), Vector2i(5, -1), Vector2i(8, -1), Vector2i(3, 3), Vector2i(7, 3), Vector2i(5, 4)]:
		_add_cell(branch)

# 52 rooms: sprawling atrium ring with inner concourse and shop bays
func _layout_mall_atrium() -> void:
	for x in range(-6, 7):
		_add_cell(Vector2i(x, -3))
		_add_cell(Vector2i(x,  3))
		_add_cell(Vector2i(x,  0))
	for y in range(-2, 3):
		_add_cell(Vector2i(-6, y))
		_add_cell(Vector2i( 6, y))
	for extra in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(-3, 2), Vector2i(3, 2), Vector2i(-3, -2), Vector2i(3, -2)]:
		_add_cell(extra)

# 20 rooms: tight square spiral — spatially disorienting
func _layout_stairwell_spiral() -> void:
	var cursor := Vector2i.ZERO
	_add_cell(cursor)
	var direction := Vector2i.RIGHT
	var leg_length := 1
	while cells.size() < room_count:
		for _repeat in 2:
			for _i in leg_length:
				cursor += direction
				_add_cell(cursor)
				if cells.size() >= room_count:
					return
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


func _create_portal(where: Vector3, target: int) -> void:
	var portal := LevelPortal.new()
	portal.name = "DoorTo_%s" % ["Offices", "DrownedHalls", "Apartments", "Tunnels", "DeadMall", "Stairwell", "Floodlights"][target]
	portal.target_level = target
	portal.position = where
	portal.portal_entered.connect(_request_level_switch)

	var trigger := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 2.8, 1.2)
	trigger.shape = shape
	trigger.position.y = 1.4
	portal.add_child(trigger)

	# Black void fill
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.0, 0.0, 0.0)
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_add_portal_box(portal, Vector3(2.0, 2.8, 0.12), Vector3(0, 1.4, 0), black)

	# Bright emissive frame — visible from far away
	var frame_color: Color = [Color(0.88, 0.76, 0.22), Color(0.18, 0.82, 0.88), Color(0.72, 0.18, 0.10), Color(0.18, 0.55, 0.32), Color(0.82, 0.68, 0.42), Color(0.42, 0.55, 0.72), Color(0.42, 0.88, 0.52)][target]
	var frame := StandardMaterial3D.new()
	frame.albedo_color = frame_color
	frame.emission_enabled = true
	frame.emission = frame_color
	frame.emission_energy_multiplier = 7.0
	_add_portal_box(portal, Vector3(0.18, 3.1, 0.22), Vector3(-1.1, 1.52, 0), frame)
	_add_portal_box(portal, Vector3(0.18, 3.1, 0.22), Vector3(1.1, 1.52, 0), frame)
	_add_portal_box(portal, Vector3(2.4, 0.18, 0.22), Vector3(0, 3.06, 0), frame)
	_add_portal_box(portal, Vector3(2.4, 0.18, 0.22), Vector3(0, 0.09, 0), frame)

	# Floor glow beams radiating outward — like a landing strip
	var glow_floor := StandardMaterial3D.new()
	glow_floor.albedo_color = frame_color * Color(0.6, 0.6, 0.6, 1.0)
	glow_floor.emission_enabled = true
	glow_floor.emission = frame_color
	glow_floor.emission_energy_multiplier = 2.5
	glow_floor.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_floor.albedo_color.a = 0.7
	var beam_dists: Array[float] = [2.0, 4.5, 7.5, 11.0, 15.0, 20.0]
	for dist: float in beam_dists:
		var alpha: float = 0.65 - dist * 0.045
		var beam_mat := glow_floor.duplicate() as StandardMaterial3D
		beam_mat.albedo_color.a = maxf(0.05, alpha)
		beam_mat.emission_energy_multiplier = maxf(0.4, 2.5 - dist * 0.18)
		_add_portal_box(portal, Vector3(0.08, 0.025, dist), Vector3(-0.65, 0.012, dist * 0.5 + 0.3), beam_mat)
		_add_portal_box(portal, Vector3(0.08, 0.025, dist), Vector3(0.65, 0.012, dist * 0.5 + 0.3), beam_mat)

	# Ceiling glow halo above the portal
	var halo := StandardMaterial3D.new()
	halo.albedo_color = frame_color * Color(0.4, 0.4, 0.4, 0.5)
	halo.emission_enabled = true
	halo.emission = frame_color
	halo.emission_energy_multiplier = 1.8
	halo.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_add_portal_box(portal, Vector3(3.5, 0.04, 3.5), Vector3(0, 3.5, 0), halo, false)

	# Strong OmniLight visible from across the whole level
	var main_light := OmniLight3D.new()
	main_light.name = "PortalLight"
	main_light.light_color = frame_color
	main_light.light_energy = 7.0
	main_light.omni_range = 35.0
	main_light.omni_attenuation = 0.5
	main_light.position = Vector3(0, 1.6, 0.4)
	main_light.shadow_enabled = true
	portal.add_child(main_light)

	# Wide soft fill light — tints walls from a distance
	var fill_light := OmniLight3D.new()
	fill_light.name = "PortalFillLight"
	fill_light.light_color = frame_color
	fill_light.light_energy = 2.5
	fill_light.omni_range = 75.0
	fill_light.omni_attenuation = 1.4
	fill_light.shadow_enabled = false

	# Vertical light shaft — visible from far away through openings
	var shaft_light := OmniLight3D.new()
	shaft_light.name = "PortalShaftLight"
	shaft_light.light_color = frame_color
	shaft_light.light_energy = 3.5
	shaft_light.omni_range = 45.0
	shaft_light.omni_attenuation = 1.6
	shaft_light.shadow_enabled = false
	shaft_light.position = Vector3(0, 4.5, 0)
	portal.add_child(shaft_light)

	# Tall emissive pillar — marks portal location from everywhere
	var pillar_mat := StandardMaterial3D.new()
	pillar_mat.albedo_color = frame_color
	pillar_mat.emission_enabled = true
	pillar_mat.emission = frame_color
	pillar_mat.emission_energy_multiplier = 1.5
	pillar_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pillar_mat.albedo_color.a = 0.35
	_add_portal_box(portal, Vector3(0.12, 8.0, 0.12), Vector3(0, 4.0, -0.8), pillar_mat, false)
	fill_light.position = Vector3(0, 2.2, 0)
	portal.add_child(fill_light)

	generated_root.add_child(portal)

func _add_portal_box(parent: Node3D, size: Vector3, pos: Vector3, material: Material, _unused := true) -> void:
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
	var player := get_node_or_null(player_path) as Node3D
	if player:
		player.global_position = Vector3(0, 0.05, 0)
		if player is CharacterBody3D:
			(player as CharacterBody3D).velocity = Vector3.ZERO
		if player.has_method("set_biome"):
			player.set_biome(current_level)
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

# 60 cells: huge open pitch — 10×6 grid with extra sideline cells.
# cell_size=10 so the pitch is 100×60 m — vast and disorienting.
func _layout_floodlights_pitch() -> void:
	for x in range(-5, 5):
		for y in range(-3, 3):
			_add_cell(Vector2i(x, y))
	# Extend along sidelines to suggest infinite length
	for x in range(-8, 8):
		_add_cell(Vector2i(x, -4))
		_add_cell(Vector2i(x,  4))
	# Tree line — one-cell-wide strip on the left (x=-9) suggesting darkness beyond
	for y in range(-4, 5):
		_add_cell(Vector2i(-9, y))

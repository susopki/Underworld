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
	room_height = [3.25, 4.1, 3.0, 3.65, 5.2, 5.8][biome]
	var palette := _palette()
	_add_box("Floor", Vector3(room_size, 0.18, room_size), Vector3(0, -0.09, 0), palette[1], true)
	_add_box("Ceiling", Vector3(room_size, 0.16, room_size), Vector3(0, room_height, 0), palette[2], true)
	_wall(0, bool(openings & 1), palette[0])
	_wall(1, bool(openings & 2), palette[0])
	_wall(2, bool(openings & 4), palette[0])
	_wall(3, bool(openings & 8), palette[0])
	_add_surface_age(palette)
	_add_ceiling_fixture()
	_add_depth_cues(palette)
	_add_biome_geometry(palette)
	_add_uncanny_props(palette)
	_add_unstable_architecture(palette)
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

func _add_surface_age(palette: Array[Material]) -> void:
	var seed: int = absi(grid_coord.x * 73856093 ^ grid_coord.y * 19349663 ^ biome * 83492791)
	var grime := _material(Color(0.015, 0.012, 0.009, 0.58), 1.0)
	grime.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var damp := _material(Color(0.04, 0.055, 0.045, 0.46), 1.0)
	damp.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var carpet_wear := _material(Color(0.9, 0.82, 0.52, 0.16), 1.0)
	carpet_wear.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for i in range(4):
		var side := posmod(seed + i, 4)
		var horizontal := side == 0 or side == 2
		var sign_value := -1.0 if side == 0 or side == 3 else 1.0
		var base := Vector3.ZERO
		var stain_width := 1.0 + float(posmod(seed >> i, 7)) * 0.37
		var stain_height := 0.28 + float(posmod(seed >> (i + 3), 5)) * 0.11
		if horizontal:
			base = Vector3(-3.4 + float(posmod(seed >> (i + 1), 7)), 0.7 + float(i) * 0.43, sign_value * room_size * 0.5 + -sign_value * 0.102)
			_add_box("WallGrime", Vector3(stain_width, stain_height, 0.025), base, grime if i % 2 == 0 else damp, false)
		else:
			base = Vector3(sign_value * room_size * 0.5 + -sign_value * 0.102, 0.7 + float(i) * 0.43, -3.4 + float(posmod(seed >> (i + 1), 7)))
			_add_box("WallGrime", Vector3(0.025, stain_height, stain_width), base, grime if i % 2 == 0 else damp, false)
	for offset in [-3.4, -1.7, 0.0, 1.7, 3.4]:
		if biome == 0:
			_add_box("CarpetTrafficWear", Vector3(1.15, 0.012, 7.8), Vector3(offset * 0.18, 0.006, 0), carpet_wear, false)
		elif biome == 1:
			_add_box("WetTileReflection", Vector3(7.4, 0.014, 0.15), Vector3(0, 0.025, offset), damp, false)
		elif biome == 4:
			_add_box("MallFloorSeam", Vector3(8.8, 0.015, 0.035), Vector3(0, 0.012, offset), palette[2], false)
	if biome == 0 or biome == 2:
		for x in [-2.5, 0.0, 2.5]:
			_add_box("CeilingTileSeamX", Vector3(0.035, 0.025, 9.6), Vector3(x, room_height - 0.09, 0), grime, false)
		for z in [-2.5, 0.0, 2.5]:
			_add_box("CeilingTileSeamZ", Vector3(9.6, 0.025, 0.035), Vector3(0, room_height - 0.09, z), grime, false)

func _add_ceiling_fixture() -> void:
	var lamp_colors: Array[Color] = [Color(1.0, 0.82, 0.42), Color(0.53, 0.92, 1.0), Color(0.78, 0.55, 0.38), Color(0.42, 0.68, 0.53), Color(1.0, 0.82, 0.56), Color(0.56, 0.66, 0.78)]
	var lamp_energies: Array[float] = [1.7, 1.3, 0.8, 0.7, 1.0, 0.6]
	var lamp_color: Color = lamp_colors[biome]
	var lamp := _emissive_material(lamp_color, lamp_energies[biome])
	var casing := _material(Color(0.045, 0.043, 0.036), 0.65)
	match biome:
		0:
			_add_box("FluorescentTubeA", Vector3(4.8, 0.055, 0.16), Vector3(0, room_height - 0.18, -1.25), lamp, false)
			_add_box("FluorescentTubeB", Vector3(4.8, 0.055, 0.16), Vector3(0, room_height - 0.18, 1.25), lamp, false)
			_add_box("LampCasing", Vector3(5.2, 0.08, 1.85), Vector3(0, room_height - 0.25, 0), casing, false)
		1:
			_add_box("PoolStripLight", Vector3(0.18, 0.06, 7.2), Vector3(-4.1, room_height - 0.2, 0), lamp, false)
			_add_box("PoolStripLight", Vector3(0.18, 0.06, 7.2), Vector3(4.1, room_height - 0.2, 0), lamp, false)
		2:
			_add_box("ApartmentBareBulbGlow", Vector3(0.42, 0.12, 0.42), Vector3(0, room_height - 0.27, 0), lamp, false)
			_add_box("ApartmentWire", Vector3(0.035, 0.55, 0.035), Vector3(0, room_height - 0.55, 0), casing, false)
		3:
			_add_box("TunnelEmergencyLight", Vector3(0.85, 0.12, 0.28), Vector3(0, room_height - 0.36, -4.35), lamp, false)
			_add_box("TunnelCableTray", Vector3(9.2, 0.09, 0.32), Vector3(0, room_height - 0.2, 3.85), casing, false)
		4:
			_add_box("DeadMallSkylightGlow", Vector3(3.8, 0.06, 2.2), Vector3(0, room_height - 0.19, 0), lamp, false)
			_add_box("SkylightFrameA", Vector3(4.2, 0.12, 0.12), Vector3(0, room_height - 0.17, -1.15), casing, false)
			_add_box("SkylightFrameB", Vector3(4.2, 0.12, 0.12), Vector3(0, room_height - 0.17, 1.15), casing, false)
		5:
			_add_box("StairwellCageLight", Vector3(0.72, 0.08, 0.72), Vector3(0, room_height - 0.28, 0), lamp, false)
			for x in [-0.42, 0.0, 0.42]:
				_add_box("LightCageBars", Vector3(0.035, 0.5, 0.035), Vector3(x, room_height - 0.54, 0.42), casing, false)

func _add_depth_cues(palette: Array[Material]) -> void:
	var darkness := _material(Color(0.0, 0.0, 0.0, 0.34), 1.0)
	darkness.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var seed: int = absi(grid_coord.x * 13 + grid_coord.y * 29 + biome * 47)
	if posmod(seed, 3) == 0:
		_add_box("NearBlackCorner", Vector3(1.8, 2.2, 0.04), Vector3(-4.91, 1.1, -3.9), darkness, false)
	if posmod(seed, 4) == 1:
		_add_box("WrongShadowPatch", Vector3(2.4, 0.03, 1.4), Vector3(2.1, 0.021, -2.9), darkness, false)
	if biome == 3 or biome == 5:
		var haze_panel := _material(Color(0.09, 0.11, 0.10, 0.22), 1.0)
		haze_panel.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_add_box("DistanceHazeSheet", Vector3(7.6, 2.1, 0.035), Vector3(0, 1.45, 4.65), haze_panel, false)

func _add_uncanny_props(palette: Array[Material]) -> void:
	var seed: int = absi(grid_coord.x * 91 + grid_coord.y * 127 + biome * 503)
	var dark := _material(Color(0.018, 0.016, 0.014), 0.92)
	var red_dim := _emissive_material(Color(0.7, 0.035, 0.02), 0.35)
	var cold_dim := _emissive_material(Color(0.22, 0.65, 0.86), 0.25)
	if posmod(seed, 5) == 0:
		var x := -3.8 + float(posmod(seed, 8))
		_add_box("HangingCable", Vector3(0.045, 1.15, 0.045), Vector3(x, room_height - 0.75, -3.9), dark, false)
		_add_box("CableEnd", Vector3(0.16, 0.08, 0.16), Vector3(x, room_height - 1.35, -3.9), dark, false)
	if posmod(seed, 7) == 2 and biome != 1:
		_add_box("DistantHumanLikeCutout", Vector3(0.52, 1.75, 0.08), Vector3(3.85, 0.88, 4.82), dark, false)
		_add_box("CutoutHead", Vector3(0.34, 0.34, 0.09), Vector3(3.85, 1.94, 4.82), dark, false)
	match biome:
		0:
			if posmod(seed, 3) == 1:
				_add_box("CollapsedOfficeTile", Vector3(1.4, 0.07, 0.86), Vector3(-2.4, room_height - 0.42, 2.8), palette[2], false).rotation_degrees.z = -8.0
				_add_box("ExitSignNoExit", Vector3(0.95, 0.3, 0.08), Vector3(0, 2.25, -4.86), red_dim, false)
		1:
			_add_box("PoolLaneLine", Vector3(0.09, 0.045, 8.6), Vector3(-1.6, 0.13, 0), cold_dim, false)
			_add_box("PoolLaneLine", Vector3(0.09, 0.045, 8.6), Vector3(1.6, 0.13, 0), cold_dim, false)
			if posmod(seed, 4) == 0:
				_add_box("SubmergedBlackShape", Vector3(1.6, 0.035, 0.42), Vector3(2.6, 0.145, 2.4), dark, false)
		2:
			if posmod(seed, 3) != 0:
				_add_box("PeelingWallpaperStrip", Vector3(0.035, 1.25, 0.72), Vector3(-4.89, 1.35, -2.7), palette[2], false).rotation_degrees.z = 5.0
			_add_box("ApartmentPeephole", Vector3(0.06, 0.06, 0.035), Vector3(2.43, 1.67, -2.3), red_dim if posmod(seed, 6) == 0 else dark, false)
		3:
			for z in [-3.2, 0.0, 3.2]:
				_add_box("TunnelFloorGrate", Vector3(1.7, 0.035, 0.36), Vector3(0, 0.025, z), dark, true)
			if posmod(seed, 4) == 1:
				_add_box("BentPipe", Vector3(0.18, 2.2, 0.18), Vector3(4.35, 1.4, -1.1), dark, false).rotation_degrees.x = 13.0
		4:
			if posmod(seed, 2) == 0:
				_add_box("StoreDisplayPedestal", Vector3(1.25, 0.85, 1.25), Vector3(-2.8, 0.42, -1.4), palette[0], true)
				_add_box("HeadlessDisplayForm", Vector3(0.42, 1.15, 0.24), Vector3(-2.8, 1.42, -1.4), dark, false)
			_add_box("DeadMallNeonLine", Vector3(2.6, 0.06, 0.06), Vector3(2.8, 2.6, -4.86), red_dim, false)
		5:
			_add_box("WrongFloorNumber", Vector3(0.58, 0.42, 0.04), Vector3(-4.88, 2.15, 0.9), red_dim if posmod(seed, 5) == 0 else dark, false)
			if posmod(seed, 3) == 2:
				_add_box("VerticalVoidSlit", Vector3(0.05, 3.4, 0.55), Vector3(4.88, 1.9, -2.4), dark, false)

func _add_unstable_architecture(palette: Array[Material]) -> void:
	var seed: int = absi(grid_coord.x * 313 + grid_coord.y * 701 + biome * 997)
	var black := _material(Color(0.0, 0.0, 0.0, 0.62), 1.0)
	black.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if posmod(seed, 4) == 0:
		var panel := _add_box("LeaningFalseWall", Vector3(0.16, room_height * 0.72, 3.2), Vector3(-3.55, room_height * 0.36, 1.1), palette[0], true)
		panel.rotation_degrees.z = -4.0 - float(posmod(seed, 5))
	if posmod(seed, 5) == 1:
		var ceiling_sag := _add_box("SaggingCeilingMass", Vector3(4.2, 0.48, 2.2), Vector3(1.2, room_height - 0.38, -1.8), palette[2], false)
		ceiling_sag.rotation_degrees.x = 3.0
	if posmod(seed, 6) == 2:
		_add_box("ImpossibleBlackGap", Vector3(2.3, 0.035, 0.08), Vector3(-1.1, 0.05, 4.86), black, false)
	if biome == 4 and posmod(seed, 3) == 0:
		var tilted_shop := _add_box("TiltedShopFacade", Vector3(3.8, 2.7, 0.16), Vector3(-2.2, 1.35, 4.72), palette[0], true)
		tilted_shop.rotation_degrees.z = 2.8
	if biome == 5 and posmod(seed, 2) == 0:
		var wrong_rail := _add_box("RailThatBlocksSight", Vector3(0.11, 0.11, 7.8), Vector3(-3.7, 1.25, 0), black, false)
		wrong_rail.rotation_degrees.x = 8.0

func _add_biome_geometry(palette: Array[Material]) -> void:
	var variant := posmod(grid_coord.x * 31 + grid_coord.y * 17, 4)
	match biome:
		0:
			if variant == 0:
				_add_box("CubicleA", Vector3(3.1, 1.35, 0.16), Vector3(-1.7, 0.67, 1.8), palette[0], true)
				_add_box("CubicleB", Vector3(0.16, 1.35, 3.0), Vector3(1.4, 0.67, -1.4), palette[0], true)
			elif variant == 1:
				_add_box("OfficeColumnA", Vector3(0.58, 3.1, 0.58), Vector3(-2.4, 1.55, -2.4), palette[0], true)
				_add_box("OfficeColumnB", Vector3(0.58, 3.1, 0.58), Vector3(2.4, 1.55, 2.4), palette[0], true)
			elif variant == 2:
				_add_box("LongPartition", Vector3(0.16, 1.55, 5.4), Vector3(-1.8, 0.77, 0.6), palette[0], true)
			else:
				_add_box("DroppedCeiling", Vector3(4.8, 0.35, 4.2), Vector3(1.8, room_height - 0.32, -1.7), palette[2], false)
		1:
			var water := _material(Color(0.08, 0.45, 0.54, 0.62), 0.08)
			water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			_add_box("PoolWater", Vector3(8.8 if variant != 2 else 5.2, 0.04, 8.8), Vector3(0, 0.08, 0), water, false)
			if variant == 0:
				for corner in [Vector3(-3.8, 1.8, -3.8), Vector3(3.8, 1.8, -3.8), Vector3(-3.8, 1.8, 3.8), Vector3(3.8, 1.8, 3.8)]:
					_add_box("PoolColumn", Vector3(0.52, 3.6, 0.52), corner, palette[0], true)
			elif variant == 1:
				_add_box("PoolBridge", Vector3(2.2, 0.18, 8.7), Vector3(-2.7, 0.12, 0), palette[1], true)
			elif variant == 2:
				_add_box("DryIsland", Vector3(3.5, 0.24, 3.5), Vector3(2.3, 0.12, -1.8), palette[1], true)
			else:
				_add_box("LowPoolArch", Vector3(8.5, 0.52, 0.5), Vector3(0, 3.15, 0), palette[0], true)
		2:
			var dark_wood := _material(Color(0.055, 0.028, 0.021), 0.9)
			if variant % 2 == 0:
				_add_box("ApartmentDivider", Vector3(4.4, 2.55, 0.18), Vector3(-2.8, 1.27, 2.35), palette[0], true)
				_add_box("FalseApartmentDoor", Vector3(1.25, 2.35, 0.08), Vector3(-2.7, 1.17, 2.23), dark_wood, false)
			else:
				_add_box("ApartmentDivider", Vector3(0.18, 2.55, 4.8), Vector3(2.6, 1.27, -2.4), palette[0], true)
				_add_box("FalseApartmentDoor", Vector3(0.08, 2.35, 1.25), Vector3(2.48, 1.17, -2.3), dark_wood, false)
			if variant == 3:
				_add_box("AbandonedCounter", Vector3(2.4, 0.9, 0.7), Vector3(-1.4, 0.45, -2.6), dark_wood, true)
		3:
			var metal := _material(Color(0.035, 0.045, 0.04), 0.38)
			if variant == 0 or variant == 2:
				_add_box("PipeA", Vector3(0.24, 0.24, 9.4), Vector3(-4.35, 2.75, 0), metal, false)
			if variant == 1 or variant == 2:
				_add_box("PipeB", Vector3(9.4, 0.2, 0.2), Vector3(0, 3.05, 4.25), metal, false)
			if variant >= 2:
				_add_box("ConcreteBeam", Vector3(10, 0.42, 0.48), Vector3(0, 2.92, 0), palette[2], true)
			if variant == 3:
				_add_box("MaintenanceBlock", Vector3(2.2, 2.1, 2.6), Vector3(3.4, 1.05, -2.8), palette[0], true)
		4:
			var shutter := _material(Color(0.11, 0.105, 0.095), 0.55)
			if variant <= 1:
				_add_box("ClosedShop", Vector3(6.2, 3.45, 0.18), Vector3(0.8, 1.72, -3.55), shutter, true)
				for x in [-1.9, -0.95, 0.0, 0.95, 1.9]:
					_add_box("ShutterLine", Vector3(0.055, 3.2, 0.24), Vector3(x + 0.8, 1.65, -3.42), palette[2], false)
			elif variant == 2:
				_add_box("MallBench", Vector3(2.6, 0.34, 0.72), Vector3(-2.5, 0.48, 2.2), _material(Color(0.16, 0.09, 0.055), 0.72), true)
			else:
				_add_box("DeadKiosk", Vector3(2.4, 1.15, 2.4), Vector3(2.5, 0.57, 1.5), shutter, true)
		5:
			var concrete := palette[0]
			if variant != 1:
				var side := -1.0 if variant == 3 else 1.0
				for step in 7:
					_add_box("ImpossibleStep", Vector3(3.4, 0.22, 0.72), Vector3(side * 1.7, 0.11 + step * 0.22, 2.6 - step * 0.7), concrete, true)
			_add_box("StairCore", Vector3(0.34, 4.8, 0.34), Vector3(-2.7, 2.4, -2.5), concrete, true)
			if variant == 1:
				_add_box("EmptyLanding", Vector3(4.6, 0.3, 4.6), Vector3(1.9, 0.15, 1.8), concrete, true)
			_add_box("Handrail", Vector3(0.1, 0.1, 5.8), Vector3(3.25, 1.55, 0.2), _material(Color(0.04, 0.045, 0.05), 0.3), false)

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
	light.light_color = [Color(1.0, 0.83, 0.47), Color(0.55, 0.88, 0.96), Color(0.72, 0.52, 0.4), Color(0.42, 0.56, 0.47), Color(0.86, 0.78, 0.62), Color(0.58, 0.66, 0.73)][biome]
	light.base_energy = [2.2, 2.7, 1.35, 1.15, 1.75, 1.2][biome]
	light.shadow_enabled = true
	add_child(light)

func _palette() -> Array[Material]:
	match biome:
		1: return [_material(Color(0.48, 0.69, 0.67)), _material(Color(0.19, 0.48, 0.52), 0.3), _material(Color(0.73, 0.78, 0.71))]
		2: return [_material(Color(0.26, 0.15, 0.13)), _material(Color(0.09, 0.045, 0.035)), _material(Color(0.28, 0.23, 0.21))]
		3: return [_material(Color(0.15, 0.17, 0.16)), _material(Color(0.055, 0.06, 0.055)), _material(Color(0.11, 0.12, 0.11))]
		4: return [_material(Color(0.31, 0.285, 0.25)), _material(Color(0.18, 0.175, 0.16), 0.38), _material(Color(0.42, 0.4, 0.35))]
		5: return [_material(Color(0.19, 0.205, 0.21)), _material(Color(0.075, 0.08, 0.085)), _material(Color(0.13, 0.14, 0.15))]
		_: return [preload("res://materials/wall.tres"), preload("res://materials/floor.tres"), preload("res://materials/ceiling.tres")]

func _material(color: Color, roughness := 0.9) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _emissive_material(color: Color, energy := 1.0) -> StandardMaterial3D:
	var material := _material(color, 0.45)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
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

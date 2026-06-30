class_name RoomModule
extends Node3D

const CLOUDS := preload("res://materials/cloud_window.tres")
const EXTERNAL_PROPS := {
	"desk":        "res://assets/models/polyhaven/metal_office_desk/metal_office_desk_1k.gltf",
	"shelf":       "res://assets/models/polyhaven/Shelf_01/Shelf_01_1k.gltf",
	"box":         "res://assets/models/polyhaven/cardboard_box_01/cardboard_box_01_1k.gltf",
	"trash":       "res://assets/models/polyhaven/metal_trash_can/metal_trash_can_1k.gltf",
	"door":        "res://assets/models/polyhaven/large_castle_door/large_castle_door_1k.gltf",
	"chair":       "res://assets/models/polyhaven/SchoolChair_01/SchoolChair_01_1k.gltf",
	"barrel":      "res://assets/models/polyhaven/Barrel_01/Barrel_01_1k.gltf",
	"table":       "res://assets/models/polyhaven/WoodenTable_01/WoodenTable_01_1k.gltf",
	"wet_sign":    "res://assets/models/polyhaven/WetFloorSign_01/WetFloorSign_01_1k.gltf",
	"armchair":    "res://assets/models/polyhaven/ArmChair_01/ArmChair_01_1k.gltf",
	"crowbar":     "res://assets/models/polyhaven/crowbar_01/crowbar_01_1k.gltf",
	"laptop":      "res://assets/models/polyhaven/classic_laptop/classic_laptop_1k.gltf",
	"cat_statue":  "res://assets/models/polyhaven/concrete_cat_statue/concrete_cat_statue_1k.gltf",
	"ladder":      "res://assets/models/polyhaven/wooden_ladder/wooden_ladder_1k.gltf",
	"monobloc":    "res://assets/models/polyhaven/plastic_monobloc_chair_01/plastic_monobloc_chair_01_1k.gltf",
	"extinguisher":"res://assets/models/polyhaven/korean_fire_extinguisher_01/korean_fire_extinguisher_01_1k.gltf",
	"bleach":      "res://assets/models/polyhaven/bleach_bottle/bleach_bottle_1k.gltf",
	"radio":       "res://assets/models/polyhaven/vintage_radio_transceiver/vintage_radio_transceiver_1k.gltf",
	"stool":       "res://assets/models/polyhaven/metal_stool_01/metal_stool_01_1k.gltf",
	"spray":       "res://assets/models/polyhaven/spray_paint_bottles/spray_paint_bottles_1k.gltf",
	"potted_plant":"res://assets/models/polyhaven/potted_plant_01/potted_plant_01_1k.gltf",
	"bench":       "res://assets/models/polyhaven/painted_wooden_bench/painted_wooden_bench_1k.gltf",
	"cash_register":"res://assets/models/polyhaven/CashRegister_01/CashRegister_01_1k.gltf",
	"coffee_cart": "res://assets/models/polyhaven/CoffeeCart_01/CoffeeCart_01_1k.gltf",
	"shop_shutter":"res://assets/models/polyhaven/rollershutter_door/rollershutter_door_1k.gltf",
	"retail_rack":    "res://assets/models/polyhaven/worn_metal_rack/worn_metal_rack_1k.gltf",
	"suitcase":       "res://assets/models/polyhaven/vintage_suitcase/vintage_suitcase_1k.gltf",
	"fire_hydrant":   "res://assets/models/polyhaven/fire_hydrant/fire_hydrant_1k.gltf",
	"alarm_clock":    "res://assets/models/polyhaven/alarm_clock_01/alarm_clock_01_1k.gltf",
	"toolbox":        "res://assets/models/polyhaven/metal_toolbox/metal_toolbox_1k.gltf",
	"trashbag":       "res://assets/models/polyhaven/trashbag/trashbag_1k.gltf",
	"ammo_box":       "res://assets/models/polyhaven/ammo_box/ammo_box_1k.gltf",
	"military_crate": "res://assets/models/polyhaven/old_military_crate/old_military_crate_1k.gltf",
	"steel_shelf":    "res://assets/models/polyhaven/steel_frame_shelves_01/steel_frame_shelves_01_1k.gltf",
	"desk_lamp":      "res://assets/models/polyhaven/desk_lamp_arm_01/desk_lamp_arm_01_1k.gltf",
	"hand_truck":     "res://assets/models/polyhaven/hand_truck/hand_truck_1k.gltf",
	"wine_bottles":   "res://assets/models/polyhaven/wine_bottles_01/wine_bottles_01_1k.gltf",
	"wooden_crate":   "res://assets/models/polyhaven/wooden_crate_01/wooden_crate_01_1k.gltf",
	"wooden_crate2":  "res://assets/models/polyhaven/wooden_crate_02/wooden_crate_02_1k.gltf",
	"street_lamp":    "res://assets/models/polyhaven/street_lamp_01/street_lamp_01_1k.gltf",
	"street_lamp2":   "res://assets/models/polyhaven/street_lamp_02/street_lamp_02_1k.gltf",
	"tire_pump":      "res://assets/models/polyhaven/tire_pump/tire_pump_1k.gltf",
}
# mass in kg — heavy props resist being knocked over
const PROP_MASSES := {
	"desk": 65.0, "shelf": 40.0, "box": 7.0, "trash": 10.0, "door": 90.0,
	"chair": 8.0, "barrel": 32.0, "table": 28.0, "wet_sign": 3.0, "armchair": 22.0, "crowbar": 4.0,
	"laptop": 2.5, "cat_statue": 18.0, "ladder": 12.0, "monobloc": 5.0, "extinguisher": 6.0, "bleach": 1.5, "radio": 8.0, "stool": 7.0, "spray": 1.0,
	"potted_plant": 14.0, "bench": 24.0, "cash_register": 9.0, "coffee_cart": 60.0, "shop_shutter": 50.0, "retail_rack": 30.0,
	"suitcase": 8.0, "fire_hydrant": 35.0, "alarm_clock": 2.0, "toolbox": 12.0, "trashbag": 4.0,
	"ammo_box": 6.0, "military_crate": 22.0, "steel_shelf": 38.0,
	"desk_lamp": 3.0, "hand_truck": 14.0, "wine_bottles": 1.2, "wooden_crate": 11.0, "wooden_crate2": 15.0,
	"street_lamp": 80.0, "street_lamp2": 30.0, "tire_pump": 4.0,
}
# approximate collision box sizes in metres (unscaled)
const PROP_COLLISION_SIZES := {
	"desk": Vector3(1.55, 0.75, 0.82), "shelf": Vector3(0.42, 1.75, 0.88),
	"box": Vector3(0.48, 0.42, 0.42), "trash": Vector3(0.38, 0.62, 0.38),
	"door": Vector3(1.15, 2.4, 0.1), "chair": Vector3(0.48, 0.85, 0.48),
	"barrel": Vector3(0.52, 0.82, 0.52), "table": Vector3(0.95, 0.75, 0.58),
	"wet_sign": Vector3(0.48, 0.88, 0.22), "armchair": Vector3(0.88, 0.95, 0.78),
	"crowbar": Vector3(0.07, 0.75, 0.05),
	"laptop": Vector3(0.38, 0.06, 0.28), "cat_statue": Vector3(0.35, 0.65, 0.35), "ladder": Vector3(0.5, 2.2, 0.12),
	"monobloc": Vector3(0.45, 0.85, 0.45), "extinguisher": Vector3(0.22, 0.55, 0.22),
	"bleach": Vector3(0.12, 0.28, 0.12), "radio": Vector3(0.38, 0.18, 0.28),
	"stool": Vector3(0.35, 0.55, 0.35), "spray": Vector3(0.18, 0.16, 0.18),
	"potted_plant": Vector3(0.59, 1.34, 0.63), "bench": Vector3(1.16, 0.89, 0.50),
	"cash_register": Vector3(0.60, 0.62, 0.44), "coffee_cart": Vector3(2.17, 1.72, 1.07),
	"shop_shutter": Vector3(1.08, 2.40, 0.30), "retail_rack": Vector3(0.92, 1.90, 0.60),
	"suitcase": Vector3(0.72, 0.30, 0.44), "fire_hydrant": Vector3(0.28, 0.55, 0.28),
	"alarm_clock": Vector3(0.14, 0.16, 0.10), "toolbox": Vector3(0.48, 0.24, 0.22),
	"trashbag": Vector3(0.44, 0.55, 0.38), "ammo_box": Vector3(0.42, 0.22, 0.26),
	"military_crate": Vector3(0.72, 0.44, 0.48), "steel_shelf": Vector3(0.56, 1.85, 0.36),
	"desk_lamp": Vector3(0.20, 0.89, 0.61), "hand_truck": Vector3(0.59, 1.40, 0.69),
	"wine_bottles": Vector3(0.18, 0.33, 0.18), "wooden_crate": Vector3(0.83, 0.35, 0.41),
	"wooden_crate2": Vector3(0.53, 0.47, 1.17),
	"street_lamp": Vector3(0.70, 3.87, 0.39), "street_lamp2": Vector3(0.39, 1.68, 0.81),
	"tire_pump": Vector3(0.25, 0.58, 0.16),
}

# Large props that should NOT have physics (block doorways when fallen)
const STATIC_PROPS := [
	"ladder",
	"shelf",
	"coffee_cart",
	"shop_shutter",
	"retail_rack",
	"steel_shelf",
	"fire_hydrant",
	"street_lamp",
	"street_lamp2",
	"desk_lamp",
]
# Real downloaded crash sounds (first that exists wins; falls back to synthesis)
const COLLAPSE_SOUNDS := ["res://audio/collapse.ogg", "res://audio/collapse.wav", "res://audio/collapse.mp3"]
const ROAR_SOUND := "res://audio/horror_stinger.wav"
var _collapsed := false
@export var biome := 0
@export var openings := 0
@export var grid_coord := Vector2i.ZERO
@export var ceiling_rift := false
@export var depth_factor := 0.0
@export var is_portal_room := false
var room_size := 10.0
var room_height := 3.25

func _ready() -> void:
	_build_room()

func _build_room() -> void:
	room_height = [3.25, 4.1, 3.0, 3.65, 5.2, 5.8, 0.0][biome]
	var palette := _palette()
	if biome == 6:
		_build_floodlights_cell(palette)
		return
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
	if not is_portal_room:
		_add_external_downloaded_props()
		_add_unstable_architecture(palette)
	_add_uncanny_props(palette)
	_add_atmosphere_effects()
	_add_room_light()
	if biome == 0 and ceiling_rift:
		_add_ceiling_rift()
	_maybe_setup_collapse()

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
		# Door jambs — vertical side posts framing the opening
		var jamb_h := room_height - 0.56
		for door_edge in [-1.3, 1.3]:
			if horizontal:
				_add_box("DoorJamb", Vector3(0.14, jamb_h, 0.22), Vector3(door_edge, jamb_h * 0.5, base.z), material, true)
			else:
				_add_box("DoorJamb", Vector3(0.22, jamb_h, 0.14), Vector3(base.x, jamb_h * 0.5, door_edge), material, true)
		# Baseboards on the wall segments flanking the opening
		if biome in [0, 2, 4, 5]:
			var bmat := _baseboard_material()
			for seg_offset in [-3.15, 3.15]:
				if horizontal:
					_add_box("Baseboard", Vector3(3.7, 0.13, 0.025), Vector3(seg_offset, 0.065, sign_value * (room_size * 0.5 - 0.016)), bmat, false)
				else:
					_add_box("Baseboard", Vector3(0.025, 0.13, 3.7), Vector3(sign_value * (room_size * 0.5 - 0.016), 0.065, seg_offset), bmat, false)
	else:
		var full_size := Vector3(room_size, room_height, 0.18) if horizontal else Vector3(0.18, room_height, room_size)
		_add_box("ClosedWall", full_size, base, material, true)
		if biome == 1:
			_add_cloud_window(side, base)
		# Baseboard along the full closed wall
		if biome in [0, 2, 4, 5]:
			var bmat := _baseboard_material()
			if horizontal:
				_add_box("Baseboard", Vector3(room_size, 0.13, 0.025), Vector3(0, 0.065, sign_value * (room_size * 0.5 - 0.016)), bmat, false)
			else:
				_add_box("Baseboard", Vector3(0.025, 0.13, room_size), Vector3(sign_value * (room_size * 0.5 - 0.016), 0.065, 0), bmat, false)

func _baseboard_material() -> StandardMaterial3D:
	match biome:
		0: return _material(Color(0.68, 0.65, 0.58), 0.88)     # Cream painted wood trim
		2: return _material(Color(0.072, 0.038, 0.028), 0.97)  # Dark wood skirting
		4: return _material(Color(0.20, 0.185, 0.16), 0.68)    # Polished dark mall trim
		5: return _material(Color(0.115, 0.125, 0.135), 0.92)  # Concrete ledge
		_: return _material(Color(0.06, 0.06, 0.06), 0.9)

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
	var cell_seed: int = absi(grid_coord.x * 73856093 ^ grid_coord.y * 19349663 ^ biome * 83492791)
	var grime := _material(Color(0.015, 0.012, 0.009, 0.58), 1.0)
	grime.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var damp := _material(Color(0.04, 0.055, 0.045, 0.46), 1.0)
	damp.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var carpet_wear := _material(Color(0.9, 0.82, 0.52, 0.16), 1.0)
	carpet_wear.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	# Deeper rooms are grimier: 4 stains near origin, up to 8 at the far end
	var grime_count := 4 + int(depth_factor * 4)
	for i in range(grime_count):
		var side := posmod(cell_seed + i, 4)
		if bool(openings & (1 << side)):
			continue  # Wall has a doorway — stains would float in the opening
		var horizontal := side == 0 or side == 2
		var sign_value := -1.0 if side == 0 or side == 3 else 1.0
		var base := Vector3.ZERO
		var stain_width := 1.0 + float(posmod(cell_seed >>i, 7)) * 0.37
		var stain_height := 0.28 + float(posmod(cell_seed >>(i + 3), 5)) * 0.11
		if horizontal:
			base = Vector3(-3.4 + float(posmod(cell_seed >>(i + 1), 7)), 0.7 + float(i % 4) * 0.43, sign_value * room_size * 0.5 + -sign_value * 0.102)
			_add_box("WallGrime", Vector3(stain_width, stain_height, 0.025), base, grime if i % 2 == 0 else damp, false)
		else:
			base = Vector3(sign_value * room_size * 0.5 + -sign_value * 0.102, 0.7 + float(i % 4) * 0.43, -3.4 + float(posmod(cell_seed >>(i + 1), 7)))
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
	var cell_seed: int = absi(grid_coord.x * 53 + grid_coord.y * 71 + biome * 113)
	var lamp_colors: Array[Color] = [Color(1.0, 0.82, 0.42), Color(0.53, 0.92, 1.0), Color(0.78, 0.55, 0.38), Color(0.42, 0.68, 0.53), Color(1.0, 0.82, 0.56), Color(0.56, 0.66, 0.78)]
	var lamp_energies: Array[float] = [2.8, 2.2, 1.5, 1.3, 1.8, 1.2]
	var lamp_color: Color = lamp_colors[biome]
	# Deep rooms may have dead fixtures
	var fixture_dead := depth_factor > 0.55 and posmod(cell_seed, 3) == 0
	var casing := _material(Color(0.045, 0.043, 0.036), 0.65)
	var lamp := _emissive_material(lamp_color, lamp_energies[biome]) if not fixture_dead else casing
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

func _add_depth_cues(_palette_unused: Array[Material]) -> void:
	# Dark transparent overlay panels removed — they cluttered doorways and over-darkened rooms.
	pass

func _add_uncanny_props(palette: Array[Material]) -> void:
	var cell_seed: int = absi(grid_coord.x * 91 + grid_coord.y * 127 + biome * 503)
	var dark := _material(Color(0.018, 0.016, 0.014), 0.92)
	var red_dim := _emissive_material(Color(0.7, 0.035, 0.02), 0.35)
	var cold_dim := _emissive_material(Color(0.22, 0.65, 0.86), 0.25)
	if posmod(cell_seed, 5) == 0:
		var x := -3.8 + float(posmod(cell_seed, 8))
		_add_box("HangingCable", Vector3(0.045, 1.15, 0.045), Vector3(x, room_height - 0.75, -3.9), dark, false)
		_add_box("CableEnd", Vector3(0.16, 0.08, 0.16), Vector3(x, room_height - 1.35, -3.9), dark, false)
	if posmod(cell_seed, 7) == 2 and biome != 1:
		_add_box("DistantHumanLikeCutout", Vector3(0.52, 1.75, 0.08), Vector3(3.85, 0.88, 4.82), dark, false)
		_add_box("CutoutHead", Vector3(0.34, 0.34, 0.09), Vector3(3.85, 1.94, 4.82), dark, false)
	match biome:
		0:
			if posmod(cell_seed, 3) == 1:
				_add_box("CollapsedOfficeTile", Vector3(1.4, 0.07, 0.86), Vector3(-2.4, room_height - 0.42, 2.8), palette[2], false).rotation_degrees.z = -8.0
				_add_box("ExitSignNoExit", Vector3(0.95, 0.3, 0.08), Vector3(0, 2.25, -4.86), red_dim, false)
		1:
			_add_box("PoolLaneLine", Vector3(0.09, 0.045, 8.6), Vector3(-1.6, 0.13, 0), cold_dim, false)
			_add_box("PoolLaneLine", Vector3(0.09, 0.045, 8.6), Vector3(1.6, 0.13, 0), cold_dim, false)
			if posmod(cell_seed, 4) == 0:
				_add_box("SubmergedBlackShape", Vector3(1.6, 0.035, 0.42), Vector3(2.6, 0.145, 2.4), dark, false)
		2:
			if posmod(cell_seed, 3) != 0:
				_add_box("PeelingWallpaperStrip", Vector3(0.035, 1.25, 0.72), Vector3(-4.89, 1.35, -2.7), palette[2], false).rotation_degrees.z = 5.0
			_add_box("ApartmentPeephole", Vector3(0.06, 0.06, 0.035), Vector3(2.43, 1.67, -2.3), red_dim if posmod(cell_seed, 6) == 0 else dark, false)
		3:
			for z in [-3.2, 0.0, 3.2]:
				_add_box("TunnelFloorGrate", Vector3(1.7, 0.035, 0.36), Vector3(0, 0.025, z), dark, true)
			if posmod(cell_seed, 4) == 1:
				_add_box("BentPipe", Vector3(0.18, 2.2, 0.18), Vector3(4.35, 1.4, -1.1), dark, false).rotation_degrees.x = 13.0
		4:
			if posmod(cell_seed, 2) == 0:
				_add_box("StoreDisplayPedestal", Vector3(1.25, 0.85, 1.25), Vector3(-2.8, 0.42, -1.4), palette[0], true)
				_add_box("HeadlessDisplayForm", Vector3(0.42, 1.15, 0.24), Vector3(-2.8, 1.42, -1.4), dark, false)
			_add_box("DeadMallNeonLine", Vector3(2.6, 0.06, 0.06), Vector3(2.8, 2.6, -4.86), red_dim, false)
		5:
			_add_box("WrongFloorNumber", Vector3(0.58, 0.42, 0.04), Vector3(-4.88, 2.15, 0.9), red_dim if posmod(cell_seed, 5) == 0 else dark, false)
			if posmod(cell_seed, 3) == 2:
				_add_box("VerticalVoidSlit", Vector3(0.05, 3.4, 0.55), Vector3(4.88, 1.9, -2.4), dark, false)

func _add_external_downloaded_props() -> void:
	var cell_seed: int = absi(grid_coord.x * 409 + grid_coord.y * 887 + biome * 1999)
	var cluster := posmod(cell_seed, 3)
	match biome:
		0:
			if cluster == 0:
				# Office setup: desk + chair + laptop on desk + trash
				_spawn_external_model("desk",   Vector3(-2.65, 0.02, -2.7),  Vector3.ONE * 1.18, Vector3(0, 90, 0))
				_spawn_external_model("chair",  Vector3(-1.3,  0.02, -2.85), Vector3.ONE * 0.95, Vector3(0, 105, 0))
				_spawn_external_model("laptop", Vector3(-2.65, 0.78, -2.7),  Vector3.ONE * 1.1,  Vector3(0, 90, 0))
				_spawn_external_model("trash",  Vector3(-3.6,  0.02, -1.85), Vector3.ONE * 0.82, Vector3(0, 15, 0))
				_spawn_external_model("desk_lamp", Vector3(-2.2, 0.78, -3.05), Vector3.ONE * 1.0, Vector3(0, -60, 0))
			elif cluster == 1:
				# Storage corner: shelf + boxes + steel rack
				_spawn_external_model("shelf", Vector3(3.88, 0.02, 1.9),  Vector3.ONE * 1.28, Vector3(0, -90, 0))
				_spawn_external_model("box",   Vector3(2.95, 0.02, 1.2),  Vector3.ONE * 0.88, Vector3(0, 22, 0))
				_spawn_external_model("box",   Vector3(2.65, 0.02, 2.55), Vector3.ONE * 0.78, Vector3(0, -8, 0))
				if posmod(cell_seed, 3) == 1:
					_spawn_external_model("alarm_clock", Vector3(3.7, 0.92, 1.9), Vector3.ONE * 1.0, Vector3(0, 20, 0))
			else:
				# Scattered: door + laptop on floor
				_spawn_external_model("door",   Vector3(0.0,  0.03, 4.54), Vector3(1.35, 1.35, 1.15), Vector3(0, 180, 0))
				_spawn_external_model("laptop", Vector3(-3.1, 0.02, 2.8),  Vector3.ONE * 1.0,  Vector3(0, -35, 8))
				if posmod(cell_seed, 5) == 3:
					_spawn_external_model("crowbar", Vector3(-2.1, 0.02, 3.8), Vector3.ONE * 1.1, Vector3(0, 45, 15))
				# Office extras
				if posmod(cell_seed, 3) == 0:
					_spawn_external_model("monobloc", Vector3(2.4, 0.02, -0.5), Vector3.ONE * 0.9, Vector3(0, -45, 0))
				if posmod(cell_seed, 4) == 1:
					_spawn_external_model("extinguisher", Vector3(4.35, 0.03, -3.4), Vector3.ONE * 0.85, Vector3(0, 90, 0))
				if posmod(cell_seed, 6) == 2:
					_spawn_external_model("radio", Vector3(-4.3, 0.02, 0.5), Vector3.ONE * 0.9, Vector3(0, 120, 0))
				if posmod(cell_seed, 7) == 3:
					_spawn_external_model("alarm_clock", Vector3(-2.65, 0.78, -1.8), Vector3.ONE * 1.0, Vector3(0, 55, 0))
				if posmod(cell_seed, 5) == 4:
					_spawn_external_model("toolbox", Vector3(3.8, 0.02, 2.2), Vector3.ONE * 0.95, Vector3(0, -30, 0))
		1:
			# Drowned: wet sign + barrel near walls + occasional cat statue
			_spawn_external_model("wet_sign", Vector3(-4.1, 0.03, 2.8), Vector3.ONE * 1.0, Vector3(0, 12, 0))
			if posmod(cell_seed, 3) == 1:
				_spawn_external_model("barrel", Vector3(3.8, 0.03, -3.2), Vector3.ONE * 0.9, Vector3(0, 35, 0))
			if posmod(cell_seed, 4) == 2:
				_spawn_external_model("trash", Vector3(-4.0, 0.04, 3.15), Vector3.ONE * 0.9, Vector3(0, 25, 0))
			if posmod(cell_seed, 5) == 0:
				_spawn_external_model("cat_statue", Vector3(1.5, 0.03, -3.6), Vector3.ONE * 1.0, Vector3(0, -20, 0))
			# Drowned extras
			if posmod(cell_seed, 3) == 0:
				_spawn_external_model("bleach", Vector3(-3.8, 0.02, -0.5), Vector3.ONE * 1.0, Vector3(0, 30, 0))
			if posmod(cell_seed, 5) == 2:
				_spawn_external_model("stool", Vector3(4.2, 0.02, 2.6), Vector3.ONE * 1.0, Vector3(0, -60, 0))
			if posmod(cell_seed, 6) == 1:
				_spawn_external_model("suitcase", Vector3(-2.1, 0.02, 3.7), Vector3.ONE * 0.95, Vector3(0, 20, 0))
		2:
			if cluster == 0:
				# Living room feel: armchair + table
				_spawn_external_model("armchair", Vector3(-2.5, 0.02, 1.8),  Vector3.ONE * 1.05, Vector3(0, 160, 0))
				_spawn_external_model("table",    Vector3(-1.0, 0.02, 2.35), Vector3.ONE * 0.85, Vector3(0, 0, 0))
			elif cluster == 1:
				# Apartment door + box
				_spawn_external_model("door", Vector3(-2.7, 0.03, 2.18), Vector3(1.05, 1.1, 0.9), Vector3(0, 0, 0))
				_spawn_external_model("box",  Vector3(-3.6, 0.03, 1.2),  Vector3.ONE * 0.9, Vector3(0, 17, 0))
			else:
				# Chair + scattered
				_spawn_external_model("chair", Vector3(2.2,  0.02, -2.5), Vector3.ONE * 1.0, Vector3(0, -30, 0))
				_spawn_external_model("box",   Vector3(-3.15, 0.03, -3.0), Vector3.ONE * 1.05, Vector3(0, 17, 0))
			# Apartment extras
			if posmod(cell_seed, 4) == 0:
				_spawn_external_model("monobloc", Vector3(-2.8, 0.02, -1.5), Vector3.ONE * 0.85, Vector3(0, 80, 0))
			if posmod(cell_seed, 5) == 1:
				_spawn_external_model("radio", Vector3(-2.2, 0.75, 0.8), Vector3.ONE * 0.95, Vector3(0, -15, 5))
				if posmod(cell_seed, 3) == 2:
					_spawn_external_model("wine_bottles", Vector3(-1.4, 0.02, -3.1), Vector3.ONE * 1.0, Vector3(0, 0, 0))
				if posmod(cell_seed, 4) == 3:
					_spawn_external_model("desk_lamp", Vector3(2.5, 0.02, 2.6), Vector3.ONE * 1.0, Vector3(0, 30, 0))
		3:
			# Maintenance cluster: barrel + box + crowbar + ladder against wall
			_spawn_external_model("barrel",  Vector3(3.95, 0.03, -2.85), Vector3.ONE * 0.85, Vector3(0, -20, 0))
			if posmod(cell_seed, 2) == 0:
				_spawn_external_model("box",     Vector3(3.2,  0.04,  2.7),  Vector3.ONE * 0.9,  Vector3(0, 37, 0))
				_spawn_external_model("crowbar", Vector3(2.55, 0.02,  2.2),  Vector3.ONE * 1.0,  Vector3(0, 80, 12))
			else:
				_spawn_external_model("trash",   Vector3(-3.5, 0.03, -1.8),  Vector3.ONE * 0.85, Vector3(0, -15, 0))
			if posmod(cell_seed, 3) == 1:
				_spawn_external_model("ladder", Vector3(-4.6, 0.02, 0.5), Vector3.ONE * 1.0, Vector3(8, 0, 0))
			_spawn_external_model("fire_hydrant", Vector3(4.55, 0.02, 3.6), Vector3.ONE * 1.0, Vector3(0, -90, 0))
			if posmod(cell_seed, 3) == 2:
				_spawn_external_model("tire_pump", Vector3(3.0, 0.02, 3.8), Vector3.ONE * 1.0, Vector3(0, 40, 0))
			if posmod(cell_seed, 5) == 0:
				_spawn_external_model("street_lamp2", Vector3(-4.4, 0.02, 1.2), Vector3.ONE * 1.0, Vector3(0, 90, 0))
			_spawn_external_model("wooden_crate", Vector3(3.4, 0.02, -0.8), Vector3.ONE * 1.0, Vector3(0, 28, 0))
			if posmod(cell_seed, 2) == 1:
				_spawn_external_model("wooden_crate2", Vector3(3.5, 0.45, -0.8), Vector3.ONE * 1.0, Vector3(0, -12, 0))
			if posmod(cell_seed, 3) == 0:
				_spawn_external_model("hand_truck", Vector3(-3.9, 0.02, 2.4), Vector3.ONE * 1.0, Vector3(0, 75, 0))
			# Tunnel extras
			if posmod(cell_seed, 2) == 0:
				_spawn_external_model("extinguisher", Vector3(-3.2, 0.03, 4.5), Vector3.ONE * 0.9, Vector3(0, 0, 0))
			if posmod(cell_seed, 3) == 2:
				_spawn_external_model("spray", Vector3(-4.2, 0.02, -3.1), Vector3.ONE * 1.0, Vector3(0, 40, -10))
			if posmod(cell_seed, 4) == 1:
				_spawn_external_model("stool", Vector3(4.5, 0.02, 3.4), Vector3.ONE * 0.95, Vector3(0, 180, 0))
			if posmod(cell_seed, 5) == 3:
				_spawn_external_model("ammo_box", Vector3(-1.8, 0.02, -4.3), Vector3.ONE * 1.0, Vector3(0, 70, 0))
			if posmod(cell_seed, 6) == 4:
				_spawn_external_model("military_crate", Vector3(3.5, 0.02, -3.8), Vector3.ONE * 1.0, Vector3(0, -15, 0))
		4:
			if cluster == 0:
				# Storefront: worn retail rack + shop shelf + planter
				_spawn_external_model("retail_rack", Vector3(-3.95, 0.02, -1.2), Vector3.ONE * 1.0, Vector3(0, 90, 0))
				_spawn_external_model("shelf",       Vector3(-3.65, 0.03,  1.6), Vector3.ONE * 1.15, Vector3(0, 90, 0))
				_spawn_external_model("potted_plant",Vector3(-2.2,  0.02, -3.6), Vector3.ONE * 1.0, Vector3(0, 0, 0))
				if posmod(cell_seed, 2) == 0:
					_spawn_external_model("cat_statue", Vector3(-1.0, 0.03, -3.8), Vector3.ONE * 0.9, Vector3(0, 45, 0))
			elif cluster == 1:
				# Food-court seating: bench + coffee cart kiosk + planter
				_spawn_external_model("bench",       Vector3(2.4,  0.02,  2.1), Vector3.ONE * 1.0, Vector3(0, -50, 0))
				_spawn_external_model("coffee_cart", Vector3(3.4,  0.02, -2.4), Vector3.ONE * 1.0, Vector3(0, 150, 0))
				_spawn_external_model("potted_plant",Vector3(1.2,  0.02,  3.8), Vector3.ONE * 1.0, Vector3(0, 0, 0))
			else:
				# Checkout counter: register + rack + box
				_spawn_external_model("cash_register", Vector3(2.6, 0.03, -2.2), Vector3.ONE * 1.0, Vector3(0, -90, 0))
				_spawn_external_model("retail_rack",   Vector3(3.9, 0.02, -1.0), Vector3.ONE * 1.0, Vector3(0, -90, 0))
				_spawn_external_model("box",           Vector3(2.0, 0.04, -3.3), Vector3.ONE * 0.85, Vector3(0, 10, 0))
			# Mall extras
			if posmod(cell_seed, 2) == 0:
				_spawn_external_model("shop_shutter", Vector3(-4.78, 0.0, 2.4), Vector3.ONE * 1.0, Vector3(0, 90, 0))
			if posmod(cell_seed, 3) == 0:
				_spawn_external_model("monobloc", Vector3(-3.5, 0.02, 2.8), Vector3.ONE * 1.0, Vector3(0, 15, 0))
				if posmod(cell_seed, 4) == 1:
					_spawn_external_model("hand_truck", Vector3(3.6, 0.02, 3.4), Vector3.ONE * 1.0, Vector3(0, -120, 0))
		5:
			if posmod(cell_seed, 2) == 1:
				_spawn_external_model("door",    Vector3(4.45, 0.03, -2.2), Vector3(1.0, 1.08, 0.9), Vector3(0, -90, 0))
			if posmod(cell_seed, 3) == 0:
				_spawn_external_model("crowbar", Vector3(-3.8, 0.02,  1.5), Vector3.ONE * 1.1, Vector3(0, 60, 18))
			if posmod(cell_seed, 2) == 0:
				_spawn_external_model("ladder",  Vector3(4.7,  0.02, -0.8), Vector3.ONE * 1.05, Vector3(5, 0, 0))
			# Stairwell extras
			if posmod(cell_seed, 3) == 0:
				_spawn_external_model("bleach", Vector3(-3.2, 0.02, 3.8), Vector3.ONE * 0.9, Vector3(0, -25, 15))
			if posmod(cell_seed, 4) == 1:
				_spawn_external_model("extinguisher", Vector3(3.5, 0.03, 4.2), Vector3.ONE * 0.85, Vector3(0, -90, 0))
			if posmod(cell_seed, 5) == 2:
				_spawn_external_model("suitcase", Vector3(-4.1, 0.02, -1.5), Vector3.ONE * 0.9, Vector3(0, 45, 0))
			if posmod(cell_seed, 6) == 3:
				_spawn_external_model("toolbox", Vector3(2.8, 0.02, 4.5), Vector3.ONE * 0.9, Vector3(0, 10, 0))

## Spawn a model as decorative debris floating (and bobbing) on the water surface.
func _spawn_floating(prop_id: String, xz: Vector2, scale_value: Vector3, rot_deg: Vector3) -> void:
	var path: String = EXTERNAL_PROPS.get(prop_id, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var res := load(path)
	if not res is PackedScene:
		return
	var visual := (res as PackedScene).instantiate()
	if not visual is Node3D:
		visual.queue_free()
		return
	var v := visual as Node3D
	v.scale = scale_value
	var raw := _visual_extent(v)
	var biggest: float = maxf(raw.x, maxf(raw.y, raw.z))
	if biggest > 6.0:
		v.scale = scale_value * (2.2 / biggest)
	var floater := Floater.new()
	floater.name = "Floating_%s" % prop_id
	floater.position = Vector3(xz.x, 0.46, xz.y)
	floater.rotation_degrees = rot_deg
	add_child(floater)
	floater.add_child(v)

## Largest per-axis mesh AABB size among all descendants (unscaled) — used to
## detect assets exported at a broken unit scale.
func _visual_extent(node: Node) -> Vector3:
	var best := Vector3.ZERO
	if node is MeshInstance3D and node.mesh:
		best = node.mesh.get_aabb().size
	for c in node.get_children():
		var s := _visual_extent(c)
		best.x = maxf(best.x, s.x)
		best.y = maxf(best.y, s.y)
		best.z = maxf(best.z, s.z)
	return best

func _spawn_external_model(prop_id: String, pos: Vector3, scale_value: Vector3, rotation_deg: Vector3) -> Node3D:
	var path: String = EXTERNAL_PROPS.get(prop_id, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource == null or not resource is PackedScene:
		return null
	var instance := (resource as PackedScene).instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return null
	var visual := instance as Node3D
	visual.scale = scale_value
	# Guard against broken assets exported at the wrong unit scale (e.g. a model exported at the wrong unit scale (e.g. a model
	# whose mesh spans tens of metres) — clamp anything absurd down to a sane size.
	var raw := _visual_extent(visual)
	var biggest: float = maxf(raw.x, maxf(raw.y, raw.z))
	if biggest > 6.0:
		visual.scale = scale_value * (2.2 / biggest)

	# Deterministic random jitter per prop per room for variety
	var jitter_seed := absi(grid_coord.x * 97 + grid_coord.y * 163 + prop_id.hash() * 37)
	var jitter_x := (posmod(jitter_seed, 59) - 29) * 0.007
	var jitter_z := (posmod(jitter_seed >> 3, 51) - 25) * 0.007
	var jitter_rot := (posmod(jitter_seed >> 6, 21) - 10) * 1.2
	var jittered_pos := pos + Vector3(jitter_x, 0.04, jitter_z)
	var jittered_rot := rotation_deg + Vector3(0, jitter_rot, 0)

	var is_static := prop_id in STATIC_PROPS
	if is_static:
		var body := StaticBody3D.new()
		body.name = "Prop_%s" % prop_id
		body.position = jittered_pos
		body.rotation_degrees = jittered_rot
		var base_size: Vector3 = PROP_COLLISION_SIZES.get(prop_id, Vector3(0.6, 0.75, 0.6))
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = base_size * scale_value
		col.position = Vector3(0, base_size.y * scale_value.y * 0.5, 0)
		col.shape = shape
		body.add_child(col)
		body.add_child(visual)
		add_child(body)
		return body
	else:
		var body := RigidBody3D.new()
		body.name = "Prop_%s" % prop_id
		body.mass = PROP_MASSES.get(prop_id, 15.0)
		body.position = jittered_pos
		body.rotation_degrees = jittered_rot
		body.sleeping = prop_id != "door"
		body.can_sleep = prop_id != "door"
		if prop_id == "door":
			# Thin, tall and top-heavy — start tilted so it topples over with a slam.
			body.rotation_degrees.x += 6.0
			body.angular_velocity = Vector3((1.0 if jitter_seed % 2 == 0 else -1.0) * 0.6, 0.0, 0.0)
		var base_size: Vector3 = PROP_COLLISION_SIZES.get(prop_id, Vector3(0.6, 0.75, 0.6))
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = base_size * scale_value
		col.position = Vector3(0, base_size.y * scale_value.y * 0.5, 0)
		col.shape = shape
		body.add_child(col)
		body.add_child(visual)
		add_child(body)
		return body

func _add_unstable_architecture(palette: Array[Material]) -> void:
	var cell_seed: int = absi(grid_coord.x * 313 + grid_coord.y * 701 + biome * 997)
	# Deeper rooms collapse more
	var collapse_chance := posmod(cell_seed, 4) == 0 or (depth_factor > 0.65 and posmod(cell_seed, 3) == 1)
	if collapse_chance:
		var panel := _add_box("LeaningFalseWall", Vector3(0.16, room_height * 0.72, 3.2), Vector3(-3.55, room_height * 0.36, 1.1), palette[0], true)
		panel.rotation_degrees.z = -4.0 - float(posmod(cell_seed, 5))
	if posmod(cell_seed, 5) == 1 or (depth_factor > 0.7 and posmod(cell_seed, 4) == 2):
		var ceiling_sag := _add_box("SaggingCeilingMass", Vector3(4.2, 0.48, 2.2), Vector3(1.2, room_height - 0.38, -1.8), palette[2], false)
		ceiling_sag.rotation_degrees.x = 3.0
	if biome == 4 and posmod(cell_seed, 3) == 0:
		var tilted_shop := _add_box("TiltedShopFacade", Vector3(3.8, 2.7, 0.16), Vector3(-2.2, 1.35, 4.72), palette[0], true)
		tilted_shop.rotation_degrees.z = 2.8

func _add_biome_geometry(palette: Array[Material]) -> void:
	var variant := posmod(grid_coord.x * 31 + grid_coord.y * 17, 6)
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
			elif variant == 3:
				_add_box("DroppedCeiling", Vector3(4.8, 0.35, 4.2), Vector3(1.8, room_height - 0.32, -1.7), palette[2], false)
			elif variant == 4:
				# Server room: rows of dead server racks
				var rack := _material(Color(0.06, 0.065, 0.07), 0.38)
				for x in [-2.5, 0.0, 2.5]:
					_add_box("ServerRack", Vector3(0.6, 2.0, 0.85), Vector3(x, 1.0, -1.5), rack, true)
					_add_box("ServerRackTop", Vector3(0.62, 0.06, 0.87), Vector3(x, 2.03, -1.5), _material(Color(0.02, 0.02, 0.02), 0.9), false)
				_add_box("CableRun", Vector3(9.0, 0.14, 0.12), Vector3(0, room_height - 0.4, -1.5), _material(Color(0.04, 0.04, 0.04), 0.5), false)
			else:
				# Break room: long counter + overhead cabinet outlines
				var counter_mat := _material(Color(0.16, 0.14, 0.11), 0.75)
				_add_box("BreakCounter", Vector3(5.4, 0.88, 0.7), Vector3(0.3, 0.44, -4.0), counter_mat, true)
				_add_box("WallCabinet", Vector3(5.0, 0.85, 0.45), Vector3(0.3, 2.2, -4.2), counter_mat, true)
				_add_box("CabinetUnderline", Vector3(5.2, 0.03, 0.48), Vector3(0.3, 1.78, -4.18), _material(Color(0.02, 0.02, 0.02), 0.9), false)
		1:
			# Drowned Halls: water covers every room at a deeper wading level.
			_add_water("Water", room_size - 0.2, room_size - 0.2, 0.5)
			# Debris floating on the surface.
			var float_seed := absi(grid_coord.x * 53 + grid_coord.y * 97 + 11)
			_spawn_floating("barrel", Vector2(-2.6, 1.8), Vector3.ONE * 0.85, Vector3(0, 20, 0))
			if posmod(float_seed, 2) == 0:
				_spawn_floating("box", Vector2(2.2, -1.4), Vector3.ONE * 0.8, Vector3(0, 40, 0))
			if posmod(float_seed, 3) == 1:
				_spawn_floating("wooden_crate", Vector2(1.2, 2.8), Vector3.ONE * 0.9, Vector3(0, -25, 0))
			if posmod(float_seed, 3) == 2:
				_spawn_floating("wine_bottles", Vector2(-1.2, -2.6), Vector3.ONE * 1.0, Vector3(0, 0, 0))
			if variant == 0:
				for corner in [Vector3(-3.8, 1.8, -3.8), Vector3(3.8, 1.8, -3.8), Vector3(-3.8, 1.8, 3.8), Vector3(3.8, 1.8, 3.8)]:
					_add_box("PoolColumn", Vector3(0.52, 3.6, 0.52), corner, palette[0], true)
			elif variant == 1:
				_add_box("PoolBridge", Vector3(2.2, 0.26, 8.7), Vector3(-2.7, 0.13, 0), palette[1], true)
			elif variant == 2:
				_add_box("DryIsland", Vector3(3.5, 0.28, 3.5), Vector3(2.3, 0.14, -1.8), palette[1], true)
			elif variant == 3:
				_add_box("LowPoolArch", Vector3(8.5, 0.52, 0.5), Vector3(0, 3.15, 0), palette[0], true)
			elif variant == 4:
				# Depth markings (ghost of former use) line the wall
				var mark := _emissive_material(Color(0.25, 0.55, 0.7), 0.2)
				_add_box("DepthMark1m", Vector3(0.6, 0.04, 0.08), Vector3(-3.7, 0.65, 0.0), mark, false)
			else:
				for cx in [-3.5, 3.5]:
					_add_box("FloodColumn", Vector3(0.42, 0.6, 0.42), Vector3(cx, 0.3, 0.0), palette[0], true)
		2:
			var dark_wood := _material(Color(0.055, 0.028, 0.021), 0.9)
			if variant == 0 or variant == 1:
				var hz := variant % 2 == 0
				if hz:
					_add_box("ApartmentDivider", Vector3(4.4, 2.55, 0.18), Vector3(-2.8, 1.27, 2.35), palette[0], true)
					_add_box("FalseApartmentDoor", Vector3(1.25, 2.35, 0.08), Vector3(-2.7, 1.17, 2.23), dark_wood, false)
				else:
					_add_box("ApartmentDivider", Vector3(0.18, 2.55, 4.8), Vector3(2.6, 1.27, -2.4), palette[0], true)
					_add_box("FalseApartmentDoor", Vector3(0.08, 2.35, 1.25), Vector3(2.48, 1.17, -2.3), dark_wood, false)
			elif variant == 2:
				_add_box("ApartmentDivider", Vector3(4.4, 2.55, 0.18), Vector3(-2.8, 1.27, 2.35), palette[0], true)
				_add_box("FalseApartmentDoor", Vector3(1.25, 2.35, 0.08), Vector3(-2.7, 1.17, 2.23), dark_wood, false)
				_add_box("AbandonedCounter", Vector3(2.4, 0.9, 0.7), Vector3(-1.4, 0.45, -2.6), dark_wood, true)
			elif variant == 3:
				_add_box("ApartmentDivider", Vector3(0.18, 2.55, 4.8), Vector3(2.6, 1.27, -2.4), palette[0], true)
				_add_box("FalseApartmentDoor", Vector3(0.08, 2.35, 1.25), Vector3(2.48, 1.17, -2.3), dark_wood, false)
				_add_box("AbandonedCounter", Vector3(2.4, 0.9, 0.7), Vector3(-1.4, 0.45, -2.6), dark_wood, true)
			elif variant == 4:
				# Kitchen: counter + stove outline + cabinet
				_add_box("KitchenCounter", Vector3(4.8, 0.9, 0.7), Vector3(0.0, 0.45, -4.1), dark_wood, true)
				_add_box("StoveOutline", Vector3(1.6, 0.06, 0.72), Vector3(-1.2, 0.93, -4.05), _material(Color(0.035, 0.035, 0.035), 0.3), false)
				_add_box("StoveBurner", Vector3(0.35, 0.04, 0.35), Vector3(-1.5, 0.97, -4.05), _material(Color(0.02, 0.02, 0.02), 0.25), false)
				_add_box("StoveBurner", Vector3(0.35, 0.04, 0.35), Vector3(-0.85, 0.97, -4.05), _material(Color(0.02, 0.02, 0.02), 0.25), false)
				_add_box("KitchenCabinet", Vector3(4.8, 0.85, 0.42), Vector3(0.0, 2.25, -4.25), dark_wood, true)
			else:
				# Living room: low platform couch + TV stub
				var fabric := _material(Color(0.08, 0.055, 0.048), 0.95)
				_add_box("CouchBase", Vector3(3.2, 0.42, 0.95), Vector3(-0.5, 0.21, 1.8), fabric, true)
				_add_box("CouchBack", Vector3(3.2, 0.65, 0.16), Vector3(-0.5, 0.74, 2.25), fabric, true)
				_add_box("CouchArmL", Vector3(0.22, 0.55, 0.95), Vector3(-2.11, 0.48, 1.8), fabric, true)
				_add_box("CouchArmR", Vector3(0.22, 0.55, 0.95), Vector3(1.11, 0.48, 1.8), fabric, true)
				_add_box("TVStand", Vector3(1.4, 0.5, 0.42), Vector3(-0.5, 0.25, -3.6), dark_wood, true)
				_add_box("TVScreen", Vector3(1.8, 1.05, 0.08), Vector3(-0.5, 1.0, -3.7), _material(Color(0.01, 0.01, 0.015), 0.06), false)
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
			elif variant == 4:
				# Pump room: large central machinery
				var machine_mat := _material(Color(0.055, 0.06, 0.055), 0.35)
				_add_box("PumpBody", Vector3(2.4, 1.8, 1.6), Vector3(0.0, 0.9, 0.0), machine_mat, true)
				_add_box("PumpTop", Vector3(2.5, 0.22, 1.7), Vector3(0.0, 1.91, 0.0), _material(Color(0.04, 0.04, 0.04), 0.4), true)
				_add_box("PipeConnectH", Vector3(0.18, 0.18, 4.8), Vector3(-3.5, 2.1, 0.0), metal, false)
				_add_box("PipeConnectV", Vector3(0.18, 1.8, 0.18), Vector3(1.2, 2.1, 2.2), metal, false)
				_add_box("ValveWheel", Vector3(0.6, 0.08, 0.6), Vector3(-3.5, 2.5, -2.0), metal, false).rotation_degrees.x = 20.0
			else:
				# Pipe junction: 4 converging pipes
				for axis_data in [[Vector3(0.22, 0.22, 9.0), Vector3(0, 1.8, 0)], [Vector3(9.0, 0.2, 0.2), Vector3(0, 2.4, 0)], [Vector3(0.16, 0.16, 7.0), Vector3(-2.0, 2.9, 0)], [Vector3(7.0, 0.16, 0.16), Vector3(0, 2.9, 2.0)]]:
					_add_box("JunctionPipe", axis_data[0], axis_data[1], metal, false)
				_add_box("JunctionBox", Vector3(0.55, 0.55, 0.55), Vector3(0.0, 1.8, 0.0), _material(Color(0.07, 0.08, 0.07), 0.4), true)
		4:
			var shutter := _material(Color(0.11, 0.105, 0.095), 0.55)
			if variant <= 1:
				_add_box("ClosedShop", Vector3(6.2, 3.45, 0.18), Vector3(0.8, 1.72, -3.55), shutter, true)
				for x in [-1.9, -0.95, 0.0, 0.95, 1.9]:
					_add_box("ShutterLine", Vector3(0.055, 3.2, 0.24), Vector3(x + 0.8, 1.65, -3.42), palette[2], false)
			elif variant == 2:
				_add_box("MallBench", Vector3(2.6, 0.34, 0.72), Vector3(-2.5, 0.48, 2.2), _material(Color(0.16, 0.09, 0.055), 0.72), true)
			elif variant == 3:
				_add_box("DeadKiosk", Vector3(2.4, 1.15, 2.4), Vector3(2.5, 0.57, 1.5), shutter, true)
			elif variant == 4:
				# Food court: low tables cluster
				var table_mat := _material(Color(0.18, 0.16, 0.13), 0.55)
				for tx in [-2.5, 0.0, 2.5]:
					_add_box("FoodTable", Vector3(1.2, 0.72, 0.8), Vector3(tx, 0.36, 1.5), table_mat, true)
					_add_box("FoodTableTop", Vector3(1.4, 0.04, 1.0), Vector3(tx, 0.74, 1.5), _material(Color(0.12, 0.11, 0.09), 0.45), false)
				_add_box("FoodCounter", Vector3(5.5, 1.1, 0.7), Vector3(0.0, 0.55, -3.6), shutter, true)
				_add_box("CounterGuard", Vector3(5.5, 0.06, 0.72), Vector3(0.0, 1.13, -3.56), _material(Color(0.06, 0.06, 0.05), 0.4), false)
			else:
				# Broken escalator: stepped geometry
				var step_mat := _material(Color(0.22, 0.2, 0.17), 0.48)
				for step in 7:
					_add_box("EscStep", Vector3(3.2, 0.18, 0.62), Vector3(-1.5, 0.09 + step * 0.38, -3.5 + step * 0.62), step_mat, true)
				_add_box("EscSide", Vector3(0.18, 2.7, 5.2), Vector3(-3.1, 1.35, -0.5), palette[0], true)
				_add_box("EscSide", Vector3(0.18, 2.7, 5.2), Vector3(0.1, 1.35, -0.5), palette[0], true)
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
			if variant == 4:
				# Observation platform: wide railed landing
				_add_box("Platform", Vector3(6.5, 0.28, 3.8), Vector3(0.0, 0.14, -2.0), concrete, true)
				for rail_x in [-3.2, 3.2]:
					_add_box("PlatformRail", Vector3(0.08, 1.05, 3.8), Vector3(rail_x, 0.9, -2.0), _material(Color(0.04, 0.04, 0.05), 0.3), true)
				_add_box("RailTop", Vector3(6.7, 0.08, 0.08), Vector3(0.0, 1.38, -2.0), _material(Color(0.04, 0.04, 0.05), 0.3), false)
			elif variant == 5:
				# Machine room: impossible gears and mechanisms
				var gear_mat := _material(Color(0.065, 0.07, 0.075), 0.3)
				_add_box("GearA", Vector3(2.2, 2.2, 0.22), Vector3(-1.8, 1.8, -3.5), gear_mat, false)
				_add_box("GearB", Vector3(1.4, 1.4, 0.18), Vector3(1.2, 1.5, -3.5), gear_mat, false)
				_add_box("GearShaft", Vector3(0.16, 0.16, 8.8), Vector3(-1.8, 1.8, 0.0), gear_mat, false)
				_add_box("MachineBase", Vector3(3.2, 0.52, 2.6), Vector3(-1.8, 0.26, -2.8), palette[0], true)

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

func _add_atmosphere_effects() -> void:
	var cell_seed: int = absi(grid_coord.x * 1117 + grid_coord.y * 2333 + biome * 4441)
	# Dust motes — subtle floating particles in organic biomes
	if biome in [0, 2, 4]:
		var particles := CPUParticles3D.new()
		particles.name = "DustMotes"
		particles.amount = 18
		particles.lifetime = 9.0
		particles.explosiveness = 0.0
		particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		particles.emission_box_extents = Vector3(4.2, 1.2, 4.2)
		particles.position = Vector3(0, 1.85, 0)
		particles.direction = Vector3(0.15 + float(posmod(cell_seed, 5)) * 0.04, 0.02, 0.08)
		particles.spread = 55.0
		particles.gravity = Vector3(0, -0.015, 0)
		particles.initial_velocity_min = 0.04
		particles.initial_velocity_max = 0.18
		particles.scale_amount_min = 0.008
		particles.scale_amount_max = 0.032
		var dust_color: Color
		if biome == 0: dust_color = Color(0.92, 0.86, 0.7, 0.35)
		elif biome == 2: dust_color = Color(0.88, 0.62, 0.42, 0.30)
		else: dust_color = Color(0.86, 0.78, 0.58, 0.28)
		particles.color = dust_color
		add_child(particles)
	# Tunnel / Stairwell: drifting haze streaks
	elif biome in [3, 5]:
		var particles := CPUParticles3D.new()
		particles.name = "HazeStreaks"
		particles.amount = 10
		particles.lifetime = 12.0
		particles.explosiveness = 0.0
		particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
		particles.emission_box_extents = Vector3(4.5, 0.4, 4.5)
		particles.position = Vector3(0, 1.2, 0)
		particles.direction = Vector3(0.1, 0.0, 0.05)
		particles.spread = 25.0
		particles.gravity = Vector3.ZERO
		particles.initial_velocity_min = 0.02
		particles.initial_velocity_max = 0.08
		particles.scale_amount_min = 0.04
		particles.scale_amount_max = 0.12
		particles.color = Color(0.3, 0.35, 0.32, 0.18)
		add_child(particles)
	# Floor mist layer — very thin, biome-tinted. Skipped in Drowned Halls: the
	# water surface already covers the floor and the mist box only muddied it.
	if biome == 1:
		return
	var mist_density := 0.08 + depth_factor * 0.06
	var mist_colors: Array[Color] = [
		Color(0.32, 0.28, 0.18, mist_density),
		Color(0.18, 0.42, 0.45, mist_density * 1.3),
		Color(0.24, 0.14, 0.12, mist_density),
		Color(0.12, 0.14, 0.12, mist_density * 0.8),
		Color(0.28, 0.24, 0.18, mist_density),
		Color(0.14, 0.16, 0.20, mist_density * 0.7),
	]
	var mist_mat := StandardMaterial3D.new()
	mist_mat.albedo_color = mist_colors[biome]
	mist_mat.roughness = 1.0
	mist_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mist_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mist_node := MeshInstance3D.new()
	mist_node.name = "FloorMist"
	var mist_mesh := BoxMesh.new()
	# Kept well inside room centre — doorways are 2.6 m wide, walls at ±5 m.
	# A 5.5 m panel clears all openings and avoids the translucent-wall glitch.
	mist_mesh.size = Vector3(5.5, 0.12, 5.5)
	mist_mesh.material = mist_mat
	mist_node.mesh = mist_mesh
	mist_node.position = Vector3(0, 0.06, 0)
	mist_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mist_node)

func _add_room_light() -> void:
	if biome == 0 and ceiling_rift:
		_add_ceiling_rift()
	var base_energies: Array[float] = [2.7, 3.1, 2.4, 2.3, 2.5, 2.35]
	var light := FlickeringLight.new()
	light.name = "BiomeLight"
	light.add_to_group("liminal_lights")
	# Sit the light at the actual ceiling fixture so its halo in fog matches the lamp.
	light.position = Vector3(0, room_height - 0.28, 0)
	light.omni_range = 11.5
	light.omni_attenuation = 1.4
	light.light_size = 0.35  # soft shadows (Forward+)
	var light_colors := [Color(1.0, 0.83, 0.47), Color(0.55, 0.88, 0.96), Color(0.72, 0.52, 0.4), Color(0.42, 0.56, 0.47), Color(0.86, 0.78, 0.62), Color(0.58, 0.66, 0.73)]
	light.light_color = light_colors[biome]
	# Deeper rooms only mildly dimmer now — dread through fog, not pitch black.
	light.base_energy = base_energies[biome] * (1.0 - depth_factor * 0.14)
	light.shadow_enabled = true
	add_child(light)
	# Dim unshadowed fill light to soften harsh shadows — placed low and off-centre
	var cell_seed := absi(grid_coord.x * 41 + grid_coord.y * 67 + biome * 89)
	var fill := OmniLight3D.new()
	fill.name = "FillLight"
	fill.position = Vector3(float(posmod(cell_seed, 5) - 2) * 1.6, 1.05, float(posmod(cell_seed >> 2, 5) - 2) * 1.6)
	fill.omni_range = 7.0
	fill.light_color = light_colors[biome].lightened(0.12)
	fill.light_energy = base_energies[biome] * 0.32 * (1.0 - depth_factor * 0.12)
	fill.shadow_enabled = false
	add_child(fill)

func _palette() -> Array[Material]:
	match biome:
		1: return [_material(Color(0.48, 0.69, 0.67)), _material(Color(0.19, 0.48, 0.52), 0.3), _material(Color(0.73, 0.78, 0.71))]
		2: return [_material(Color(0.26, 0.15, 0.13)), _material(Color(0.09, 0.045, 0.035)), _material(Color(0.28, 0.23, 0.21))]
		3: return [_material(Color(0.15, 0.17, 0.16)), _material(Color(0.055, 0.06, 0.055)), _material(Color(0.11, 0.12, 0.11))]
		4: return [_material(Color(0.31, 0.285, 0.25)), _material(Color(0.18, 0.175, 0.16), 0.38), _material(Color(0.42, 0.4, 0.35))]
		5: return [_material(Color(0.19, 0.205, 0.21)), _material(Color(0.075, 0.08, 0.085)), _material(Color(0.13, 0.14, 0.15))]
		6: # Floodlights: damp green pitch grass, worn white paint
			return [_material(Color(0.10, 0.18, 0.08), 1.0), _material(Color(0.09, 0.17, 0.06), 1.0), _material(Color(0.2, 0.24, 0.16))]
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

## Some rooms (not spawn, not portal) collapse when the player walks in.
func _maybe_setup_collapse() -> void:
	if is_portal_room or grid_coord == Vector2i.ZERO:
		return
	var collapse_seed := absi(grid_coord.x * 71 + grid_coord.y * 191 + biome * 313)
	if posmod(collapse_seed, 26) != 0:
		return
	var area := Area3D.new()
	area.name = "CeilingCollapseTrigger"
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(room_size * 0.55, room_height, room_size * 0.55)
	col.shape = shape
	col.position = Vector3(0, room_height * 0.5, 0)
	area.add_child(col)
	add_child(area)
	area.body_entered.connect(_on_collapse_entered)

func _on_collapse_entered(body: Node3D) -> void:
	if _collapsed or not (body is PlayerController or body is VRPlayerController or body.is_in_group("player")):
		return
	_collapsed = true
	_play_collapse_sound()
	_spawn_falling_debris()
	# Brief beat so the crash lands, then the player is knocked to the floor.
	get_tree().create_timer(0.22).timeout.connect(func() -> void:
		if is_instance_valid(body) and body.has_method("knock_down"):
			body.knock_down(10.0)
	)
	# A roar in the dark while the player is down.
	if ResourceLoader.exists(ROAR_SOUND):
		get_tree().create_timer(1.6).timeout.connect(func() -> void:
			if not is_instance_valid(self):
				return
			var roar := AudioStreamPlayer3D.new()
			roar.stream = load(ROAR_SOUND)
			roar.volume_db = 2.0
			roar.max_distance = 50.0
			roar.unit_size = 14.0
			roar.finished.connect(roar.queue_free)
			add_child(roar)
			roar.position = Vector3(0, 1.4, -room_size * 0.4)
			roar.play()
		)

func _play_collapse_sound() -> void:
	var stream: AudioStream = null
	for path in COLLAPSE_SOUNDS:
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	if stream == null:
		stream = _make_crash_fallback()
	var src := AudioStreamPlayer3D.new()
	src.stream = stream
	src.volume_db = 5.0
	src.max_distance = 64.0
	src.unit_size = 18.0
	src.finished.connect(src.queue_free)
	add_child(src)
	src.position = Vector3(0, room_height, 0)
	src.play()

func _spawn_falling_debris() -> void:
	var chunk_mat := _palette()[2]
	var debris_seed := absi(grid_coord.x * 37 + grid_coord.y * 53 + 7)
	for i in 18:
		var size := Vector3(
			0.5 + float(posmod(debris_seed + i * 13, 7)) * 0.18,
			0.12 + float(posmod(debris_seed + i * 7, 4)) * 0.06,
			0.5 + float(posmod(debris_seed + i * 17, 7)) * 0.18)
		var rb := RigidBody3D.new()
		rb.name = "CeilingChunk"
		rb.mass = 6.0
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		rb.add_child(col)
		var mesh := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = size
		bm.material = chunk_mat
		mesh.mesh = bm
		rb.add_child(mesh)
		add_child(rb)
		var px := -room_size * 0.45 + float(posmod(debris_seed + i * 29, 101)) / 101.0 * room_size * 0.9
		var pz := -room_size * 0.45 + float(posmod(debris_seed + i * 41, 101)) / 101.0 * room_size * 0.9
		rb.position = Vector3(px, room_height - 0.12 - float(i % 3) * 0.28, pz)
		rb.angular_velocity = Vector3(posmod(i, 5) - 2, posmod(i, 3) - 1, posmod(i, 7) - 3)

func _make_crash_fallback() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 2.3
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 8821
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.5)
		var env := exp(-t * 1.7) * (1.0 + 0.7 * exp(-t * 13.0))
		var rumble := sin(TAU * (72.0 - t * 22.0) * t) * 0.6
		var value := (filtered * 0.7 + rumble) * env
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 21000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav

static var _shared_water_mat: ShaderMaterial

func _water_material() -> ShaderMaterial:
	if _shared_water_mat == null:
		_shared_water_mat = ShaderMaterial.new()
		_shared_water_mat.shader = load("res://shaders/water.gdshader")
	return _shared_water_mat

## Single optimized water plane (one shared material, shadows off) — replaces stacked transparent boxes.
func _add_water(node_name: String, size_x: float, size_z: float, y: float) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var plane := PlaneMesh.new()
	plane.size = Vector2(size_x, size_z)
	node.mesh = plane
	node.material_override = _water_material()
	node.position = Vector3(0, y, 0)
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node

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

## Floodlights biome: each "room" is a 10×10 m open pitch cell — no walls, no ceiling.
## The grid produces an endless-feeling football field.
func _build_floodlights_cell(palette: Array[Material]) -> void:
	var cell_seed: int = absi(grid_coord.x * 40507 + grid_coord.y * 28019 + 6 * 91273)

	# Grass floor — muddy, worn, slightly dark green
	_add_box("PitchFloor", Vector3(room_size, 0.12, room_size), Vector3(0, -0.06, 0), palette[1], true)

	# White line markings (UV-faded, worn paint)
	var line_mat := _emissive_material(Color(0.72, 0.76, 0.65), 0.06)
	# Centre line
	_add_box("CentreLine", Vector3(room_size, 0.015, 0.18), Vector3(0, 0.008, 0), line_mat, false)
	_add_box("SideLine", Vector3(0.18, 0.015, room_size), Vector3(0, 0.008, 0), line_mat, false)

	# Muddy puddle patches — deterministic per cell
	var mud := _material(Color(0.038, 0.028, 0.016), 1.0)
	if posmod(cell_seed, 3) != 2:
		var px := -3.5 + float(posmod(cell_seed, 7))
		var pz := -3.0 + float(posmod(cell_seed >> 2, 6))
		_add_box("MudPatch", Vector3(2.2 + float(posmod(cell_seed, 4)) * 0.4, 0.012, 1.4 + float(posmod(cell_seed >> 4, 3)) * 0.3), Vector3(px, 0.007, pz), mud, false)

	# Goalpost — only on cells along the far ends of the pitch (y coord ±4)
	if abs(grid_coord.y) == 4 and posmod(grid_coord.x + 5, 3) == 0:
		_build_goalpost()

	# Floodlight masts only line the pitch perimeter (the two long sidelines),
	# pushed to the outer edge of the cell — never scattered across the field.
	if abs(grid_coord.y) == 4 and posmod(grid_coord.x, 3) == 0:
		var edge_z := 4.6 if grid_coord.y > 0 else -4.6
		_build_floodlight_mast(Vector3(0.0, 0.0, edge_z), cell_seed)

	# Sparse props on sideline cells
	if grid_coord.x == -9:
		_build_treeline_cell(cell_seed, palette)
		if posmod(grid_coord.y, 2) == 0:
			_spawn_external_model("street_lamp", Vector3(4.2, 0.0, 0.0), Vector3.ONE * 1.0, Vector3(0, -90, 0))
	else:
		if posmod(cell_seed, 7) == 0:
			_spawn_external_model("trashbag", Vector3(-4.0, 0.02, 3.5), Vector3.ONE * 1.0, Vector3(0, float(posmod(cell_seed, 36)) * 10.0, 0))
		if posmod(cell_seed, 9) == 3:
			_spawn_external_model("ammo_box", Vector3(3.8, 0.02, -3.2), Vector3.ONE * 1.0, Vector3(0, 45.0, 0))

	# Portal room: add fog surge zone marker
	if is_portal_room:
		var glow := _emissive_material(Color(0.42, 0.88, 0.52), 0.25)
		glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glow.albedo_color = Color(0.42, 0.88, 0.52, 0.18)
		_add_box("ExitGlow", Vector3(3.0, 0.02, 3.0), Vector3(0, 0.01, 0), glow, false)

	# Collapse setup still applies
	_maybe_setup_collapse()

	# Atmosphere: thick ground mist + particles
	_add_floodlights_atmosphere()

	# Room light: dim bluish-green point (moonlight feel, far above)
	var sky_light := OmniLight3D.new()
	sky_light.name = "SkyAmbient"
	sky_light.light_color = Color(0.4, 0.72, 0.46)
	sky_light.light_energy = 0.75
	sky_light.omni_range = 22.0
	sky_light.shadow_enabled = false
	sky_light.add_to_group("liminal_lights")
	sky_light.position = Vector3(0, 12.0, 0)
	add_child(sky_light)

func _build_goalpost() -> void:
	var metal := _material(Color(0.72, 0.72, 0.7), 0.25)
	# Two uprights
	_add_box("PostLeft",  Vector3(0.12, 2.55, 0.12), Vector3(-3.66, 1.275, 0), metal, true)
	_add_box("PostRight", Vector3(0.12, 2.55, 0.12), Vector3( 3.66, 1.275, 0), metal, true)
	# Crossbar
	_add_box("Crossbar",  Vector3(7.32, 0.12, 0.12), Vector3(0, 2.55, 0), metal, false)
	# Net suggestion (transparent dark mesh)
	var net_mat := _material(Color(0.06, 0.07, 0.06), 0.9)
	net_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	net_mat.albedo_color.a = 0.55
	_add_box("NetBack",   Vector3(7.32, 2.55, 0.06), Vector3(0, 1.275, -1.8), net_mat, false)
	_add_box("NetTop",    Vector3(7.32, 0.06, 1.8),  Vector3(0, 2.55, -0.9),  net_mat, false)

func _build_floodlight_mast(offset: Vector3, cell_seed: int) -> void:
	var steel := _material(Color(0.18, 0.19, 0.17), 0.35)
	# Pole
	_add_box("MastPole", Vector3(0.22, 14.0, 0.22), offset + Vector3(0, 7.0, 0), steel, true)
	# Crossarm
	_add_box("MastArm", Vector3(2.4, 0.18, 0.18), offset + Vector3(0, 13.8, 0), steel, false)

	# Floodlight heads — SpotLight3D, cold green-white. Aimed inward across the
	# pitch so the cones rake through the volumetric fog into visible beams.
	var light_color := Color(0.78, 0.96, 0.82)
	# Point the beams toward field centre (offset is at a cell corner/edge).
	var aim_yaw := rad_to_deg(atan2(-offset.x, -offset.z))
	for dx in [-1.0, 0.0, 1.0]:
		var spot := SpotLight3D.new()
		spot.name = "FloodSpot"
		spot.light_color = light_color
		spot.light_energy = 7.0 + float(posmod(cell_seed, 4)) * 0.6
		spot.spot_range = 46.0
		spot.spot_angle = 30.0
		spot.spot_attenuation = 0.35
		spot.shadow_enabled = true
		spot.position = offset + Vector3(dx, 14.2, 0)
		# ~55° down (more horizontal than before) so the beam travels far through fog.
		spot.rotation_degrees = Vector3(-55.0, aim_yaw + float(dx) * 12.0, 0)
		spot.add_to_group("liminal_lights")
		add_child(spot)

		# Bright emissive head + soft glow halo box.
		var head_mat := _emissive_material(light_color, 7.0)
		_add_box("LampHead", Vector3(0.6, 0.18, 0.42), offset + Vector3(dx, 13.85, 0), head_mat, false)

func _build_treeline_cell(cell_seed: int, _palette_unused: Array[Material]) -> void:
	# Dark tree silhouettes — capsule + sphere, nearly black
	var bark := _material(Color(0.02, 0.024, 0.018), 0.95)
	var leaf := _material(Color(0.015, 0.022, 0.012), 1.0)
	var tree_count := 2 + posmod(cell_seed, 3)
	for i in tree_count:
		var tx := -3.5 + float(i) * (7.0 / maxf(float(tree_count - 1), 1.0))
		var theight := 5.5 + float(posmod(cell_seed + i * 13, 5)) * 0.7
		_add_box("TreeTrunk_%d" % i, Vector3(0.28, theight, 0.28), Vector3(tx, theight * 0.5, 0), bark, true)
		# Crown
		var crown := MeshInstance3D.new()
		crown.name = "TreeCrown_%d" % i
		var mesh := SphereMesh.new()
		mesh.radius = 1.4 + float(posmod(cell_seed + i * 7, 4)) * 0.25
		mesh.height = mesh.radius * 2.0
		mesh.radial_segments = 6
		mesh.rings = 3
		mesh.material = leaf
		crown.mesh = mesh
		crown.position = Vector3(tx, theight + mesh.radius * 0.7, 0)
		add_child(crown)
	# Darkness behind — black wall
	var void_mat := _material(Color(0.002, 0.003, 0.002), 1.0)
	_add_box("ForestVoid", Vector3(0.16, 8.0, room_size), Vector3(-4.85, 4.0, 0), void_mat, true)

func _add_floodlights_atmosphere() -> void:
	# Thick low-lying ground fog — denser than other biomes
	var mist_mat := StandardMaterial3D.new()
	mist_mat.albedo_color = Color(0.15, 0.26, 0.16, 0.22 + depth_factor * 0.08)
	mist_mat.roughness = 1.0
	mist_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mist_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mist := MeshInstance3D.new()
	mist.name = "PitchMist"
	var mist_mesh := BoxMesh.new()
	mist_mesh.size = Vector3(5.5, 0.28, 5.5)
	mist_mesh.material = mist_mat
	mist.mesh = mist_mesh
	mist.position = Vector3(0, 0.14, 0)
	mist.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mist)

	# Floating moisture particles — light drizzle feel
	var p := CPUParticles3D.new()
	p.name = "Drizzle"
	p.amount = 22
	p.lifetime = 5.0
	p.explosiveness = 0.0
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(4.5, 2.0, 4.5)
	p.position = Vector3(0, 3.0, 0)
	p.direction = Vector3(0.06, -1.0, 0.04)
	p.spread = 8.0
	p.gravity = Vector3(0, -0.4, 0)
	p.initial_velocity_min = 0.3
	p.initial_velocity_max = 0.8
	p.scale_amount_min = 0.006
	p.scale_amount_max = 0.018
	p.color = Color(0.55, 0.72, 0.58, 0.45)
	add_child(p)

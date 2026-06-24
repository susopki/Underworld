class_name ScareEventManager
extends Node

const EVENT_COUNT := 22

@export var player_path: NodePath
@export var level_path: NodePath
@export var sound_path: NodePath
@export var atmosphere_path: NodePath
var player: PlayerController
var level: LevelGenerator
var sounds: RandomSoundManager
var atmosphere: AtmosphereManager
var _timer := 20.0
var _last_anomaly_band := 999999
var _last_event := -1
var _rng := RandomNumberGenerator.new()
var _stalker: Stalker

func _ready() -> void:
	_rng.randomize()
	player = get_node(player_path)
	level = get_node(level_path)
	sounds = get_node(sound_path)
	atmosphere = get_node(atmosphere_path)
	sounds.player = player
	_timer = _rng.randf_range(20.0, 36.0)

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		# Rare "stalker" scare (comparable odds to the ceiling collapse).
		if not is_instance_valid(_stalker) and _rng.randf() < 0.13:
			_trigger_stalker()
		else:
			var next_event := _rng.randi_range(0, EVENT_COUNT - 1)
			while next_event == _last_event:
				next_event = _rng.randi_range(0, EVENT_COUNT - 1)
			_last_event = next_event
			_run_event(next_event)
		_timer = _rng.randf_range(24.0, 52.0)
	# Invisible anomaly bands recur deep in the architecture.
	var radial_distance := Vector2(player.global_position.x, player.global_position.z).length()
	var band := int(floor(radial_distance / 42.0))
	if band > 0 and band != _last_anomaly_band and fmod(radial_distance, 42.0) < 5.0:
		_last_anomaly_band = band
		atmosphere.pulse_anomaly(0.7)

func _run_event(event_id: int) -> void:
	match event_id:
		0:
			level.flicker_all(_rng.randf_range(2.0, 4.5))
			atmosphere.pulse_anomaly(0.45)
		1:
			sounds.play_distant_steps()
		2:
			sounds.play_wall_breath()
			atmosphere.pulse_anomaly(0.25)
		3:
			_spawn_shadow()
		4:
			if Vector2(player.global_position.x, player.global_position.z).length() > 14.0:
				level.seal_space_behind(player)
				atmosphere.pulse_anomaly(0.9)
			else:
				_spawn_shadow()
		5:
			level.spawn_phantom_door(player)
			sounds.play_distant_steps()
		6:
			atmosphere.fog_surge(_rng.randf_range(0.65, 1.0), _rng.randf_range(4.0, 8.0))
			sounds.play_whisper()
		7:
			level.blackout_all(_rng.randf_range(2.0, 4.5))
			sounds.silence_hum(3.5)
			get_tree().create_timer(1.4).timeout.connect(sounds.play_wall_breath)
		8:
			sounds.play_metal_slam()
			level.light_wave(player)
		9:
			sounds.play_ceiling_scrape()
			atmosphere.pulse_anomaly(0.28)
		10:
			sounds.silence_hum(_rng.randf_range(4.0, 7.0))
			get_tree().create_timer(2.2).timeout.connect(sounds.play_distant_steps)
		11:
			sounds.play_electrical_pop()
			level.light_wave(player)
		12:
			level.spawn_phantom_door(player)
			atmosphere.pulse_anomaly(0.78)
		13:
			_spawn_shadow(0)
			atmosphere.fog_surge(0.55, 3.5)
		14:
			_spawn_shadow(1, true)
			sounds.play_reverse_hit()
			atmosphere.pulse_anomaly(0.92)
		15:
			_spawn_shadow_family()
			sounds.play_phantom_chord()
			level.flicker_all(1.8)
		16:
			_spawn_shadow(2, false, 5.2)
			sounds.play_close_knock()
			atmosphere.pulse_anomaly(0.68)
		17:
			sounds.play_low_drone(5.5)
			atmosphere.fog_surge(1.15, 5.0)
			get_tree().create_timer(1.0).timeout.connect(func(): _spawn_shadow(3, true))
		18:
			level.blackout_all(2.2)
			sounds.play_reverse_hit()
			get_tree().create_timer(0.55).timeout.connect(func(): _spawn_shadow(4, true, 9.0))
		19:
			level.light_wave(player)
			sounds.play_ceiling_crawl()
			_spawn_shadow(5, false, 11.0)
		20:
			sounds.play_wall_breath(true)
			atmosphere.pulse_anomaly(1.0)
			get_tree().create_timer(0.45).timeout.connect(func(): _spawn_shadow(6, false, 4.6))
		21:
			level.spawn_phantom_door(player)
			_spawn_shadow(7, true, 13.0)
			sounds.silence_hum(4.2)

## Knock behind the player; a tall black figure is now standing there. Turn to
## face it and it knocks you off your feet.
func _trigger_stalker() -> void:
	var back := player.global_transform.basis.z.normalized()  # +Z is behind the camera
	var spawn := player.global_position + back * 5.0
	_stalker = Stalker.new()
	_stalker.target = player
	level.get_parent().add_child(_stalker)
	_stalker.global_position = Vector3(spawn.x, 0.0, spawn.z)
	sounds.play_knock_at(_stalker.global_position + Vector3(0, 1.0, 0))
	atmosphere.pulse_anomaly(0.85)

func _spawn_shadow(entity_variant := 0, in_front := false, forced_distance := -1.0) -> void:
	if get_tree().get_first_node_in_group("shadow_entity"):
		return
	var entity := BiomeEntity.new()
	entity.biome = level.current_level
	entity.entity_variant = entity_variant
	entity.target = player
	entity.add_to_group("shadow_entity")
	level.get_parent().add_child(entity)
	if in_front or forced_distance > 0.0:
		var forward := -player.global_transform.basis.z.normalized()
		var right := player.global_transform.basis.x.normalized()
		var distance := forced_distance if forced_distance > 0.0 else _rng.randf_range(10.0, 18.0)
		entity.global_position = player.global_position + forward * distance + right * _rng.randf_range(-2.2, 2.2)
	else:
		entity.global_position = level.get_entity_spawn_position(player)
	entity.look_at(Vector3(player.global_position.x, entity.global_position.y, player.global_position.z), Vector3.UP)
	atmosphere.pulse_anomaly(0.32)

func _spawn_shadow_family() -> void:
	if get_tree().get_first_node_in_group("shadow_entity"):
		return
	var forward := -player.global_transform.basis.z.normalized()
	var right := player.global_transform.basis.x.normalized()
	for i in range(4):
		var entity := BiomeEntity.new()
		entity.biome = level.current_level
		entity.entity_variant = 10 + i
		entity.target = player
		entity.add_to_group("shadow_entity")
		level.get_parent().add_child(entity)
		entity.global_position = player.global_position + forward * (12.5 + float(i) * 1.2) + right * (-2.4 + float(i) * 1.6)
		entity.look_at(Vector3(player.global_position.x, entity.global_position.y, player.global_position.z), Vector3.UP)
	atmosphere.pulse_anomaly(0.86)

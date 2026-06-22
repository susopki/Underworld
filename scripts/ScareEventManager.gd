class_name ScareEventManager
extends Node

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
		var next_event := _rng.randi_range(0, 13)
		while next_event == _last_event:
			next_event = _rng.randi_range(0, 13)
		_last_event = next_event
		_run_event(next_event)
		_timer = _rng.randf_range(28.0, 58.0)
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
			_spawn_shadow()
			atmosphere.fog_surge(0.55, 3.5)

func _spawn_shadow() -> void:
	if get_tree().get_first_node_in_group("shadow_entity"):
		return
	var entity := BiomeEntity.new()
	entity.biome = level.current_level
	entity.target = player
	entity.add_to_group("shadow_entity")
	level.get_parent().add_child(entity)
	entity.global_position = level.get_entity_spawn_position(player)
	atmosphere.pulse_anomaly(0.32)

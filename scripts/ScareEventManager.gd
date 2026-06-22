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
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	player = get_node(player_path)
	level = get_node(level_path)
	sounds = get_node(sound_path)
	atmosphere = get_node(atmosphere_path)
	sounds.player = player
	_timer = _rng.randf_range(16.0, 28.0)

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_run_event(_rng.randi_range(0, 5))
		_timer = _rng.randf_range(22.0, 48.0)
	# Invisible anomaly bands recur deep in the architecture.
	var band := int(floor(abs(player.global_position.z) / 54.0))
	if band > 0 and band != _last_anomaly_band and fmod(abs(player.global_position.z), 54.0) < 7.0:
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
			if player.global_position.z < -20.0:
				level.seal_space_behind(player)
				atmosphere.pulse_anomaly(0.9)
			else:
				_spawn_shadow()
		5:
			level.extend_space(_rng.randi_range(2, 5))
			level.flicker_all(1.6)

func _spawn_shadow() -> void:
	if get_tree().get_first_node_in_group("shadow_entity"):
		return
	var entity := BiomeEntity.new()
	entity.biome = level.current_level
	entity.target = player
	entity.add_to_group("shadow_entity")
	get_tree().current_scene.add_child(entity)
	entity.global_position = level.get_entity_spawn_position(player)
	atmosphere.pulse_anomaly(0.32)

class_name LevelTransitionManager
extends Node

@export var player_path: NodePath
@export var atmosphere_path: NodePath
@export var level_path: NodePath
@export var sounds_path: NodePath
@export var zone_length := 60.0

var player: PlayerController
var atmosphere: AtmosphereManager
var level: LevelGenerator
var sounds: RandomSoundManager
var current_zone := 0
var transition_locked := false

func _ready() -> void:
	player = get_node(player_path)
	atmosphere = get_node(atmosphere_path)
	level = get_node(level_path)
	sounds = get_node(sounds_path)

func _process(_delta: float) -> void:
	var zone := maxi(0, int(floor(-player.global_position.z / zone_length)))
	if zone != current_zone and not transition_locked:
		current_zone = zone
		_transition_to(posmod(zone, 4))

func _transition_to(zone_id: int) -> void:
	transition_locked = true
	atmosphere.set_zone(zone_id)
	level.flicker_all(1.2)
	if zone_id == 1 or zone_id == 3:
		sounds.play_wall_breath()
	else:
		sounds.play_distant_steps()
	get_tree().create_timer(2.4).timeout.connect(func(): transition_locked = false)


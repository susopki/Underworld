class_name PlayerController
extends CharacterBody3D

@export var walk_speed := 2.35
@export var acceleration := 7.0
@export var mouse_sensitivity := 0.0018
@export var gravity := 18.0
@onready var head: Node3D = $Head

var _pitch := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_add_breathing()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -1.35, 1.35)
		head.rotation.x = _pitch
	if event.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var target := direction * walk_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
	move_and_slide()

func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

func _add_breathing() -> void:
	var player := AudioStreamPlayer.new()
	player.name = "Breathing"
	player.volume_db = -25.0
	player.stream = _breath_wave()
	add_child(player)
	player.play()

func _breath_wave() -> AudioStreamWAV:
	var rate := 22050
	var duration := 5.6
	var count := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7319
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerp(filtered, rng.randf_range(-1.0, 1.0), 0.075)
		var envelope := pow(max(0.0, sin(TAU * t / duration)), 1.7)
		var pulse := 0.6 + 0.4 * sin(TAU * t * 0.22)
		bytes.encode_s16(i * 2, int(clamp(filtered * envelope * pulse, -1.0, 1.0) * 15000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = count
	wav.data = bytes
	return wav

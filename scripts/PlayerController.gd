class_name PlayerController
extends CharacterBody3D

@export var walk_speed := 2.35
@export var acceleration := 7.0
@export var mouse_sensitivity := 0.0018
@export var gravity := 18.0
const STEP_HEIGHT := 0.30
@onready var head: Node3D = $Head

var _pitch := 0.0
var noclip := false
var fly_speed := 8.0
var _knocked := false
var _head_rest_y := 1.58
var _eyelids: ColorRect
var _flashlight: SpotLight3D
var current_biome := 0
var _step_timer := 0.0
var _step_sounds: Array[AudioStreamWAV] = []
var _step_player: AudioStreamPlayer

func set_noclip(enabled: bool) -> void:
	noclip = enabled
	$CollisionShape3D.set_deferred("disabled", enabled)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Snap back down onto step tops after stepping up.
	floor_snap_length = STEP_HEIGHT + 0.1
	_head_rest_y = head.position.y
	_build_eyelids()
	_build_flashlight()
	_add_breathing()
	_build_step_audio()

func _build_flashlight() -> void:
	# Dim handheld light, aimed where the camera looks. Toggle with 1.
	_flashlight = SpotLight3D.new()
	_flashlight.name = "Flashlight"
	_flashlight.light_color = Color(1.0, 0.95, 0.82)
	_flashlight.light_energy = 1.1
	_flashlight.spot_range = 13.0
	_flashlight.spot_angle = 32.0
	_flashlight.spot_attenuation = 1.4
	_flashlight.shadow_enabled = true
	_flashlight.position = Vector3(0.12, -0.18, 0.0)
	_flashlight.visible = false
	head.get_node("Camera3D").add_child(_flashlight)

func _build_eyelids() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	_eyelids = ColorRect.new()
	_eyelids.color = Color(0, 0, 0, 0)
	_eyelids.anchor_right = 1.0
	_eyelids.anchor_bottom = 1.0
	_eyelids.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_eyelids)

## Player gets knocked to the floor, eyes close (black), then comes to after black_time.
func knock_down(black_time := 10.0) -> void:
	if _knocked:
		return
	_knocked = true
	velocity = Vector3.ZERO
	var fall := create_tween()
	fall.set_parallel(true)
	fall.tween_property(head, "position:y", 0.22, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall.tween_property(head, "rotation:z", deg_to_rad(72.0), 0.7).set_trans(Tween.TRANS_BACK)
	fall.tween_property(_eyelids, "color:a", 1.0, 0.85).set_delay(0.35)
	await get_tree().create_timer(0.85 + black_time).timeout
	var wake := create_tween()
	wake.set_parallel(true)
	wake.tween_property(_eyelids, "color:a", 0.0, 1.4)
	wake.tween_property(head, "position:y", _head_rest_y, 0.9).set_trans(Tween.TRANS_SINE)
	wake.tween_property(head, "rotation:z", 0.0, 0.9).set_trans(Tween.TRANS_SINE)
	await wake.finished
	_knocked = false

func _input(event: InputEvent) -> void:
	if _knocked:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_1:
		if _flashlight:
			_flashlight.visible = not _flashlight.visible
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -1.35, 1.35)
		head.rotation.x = _pitch
	if event.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	if _knocked:
		velocity = Vector3.ZERO
		return
	if noclip:
		_fly(delta)
		return
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input.x, 0.0, input.y)).normalized()
	var target := direction * walk_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
	# Footstep timing
	_step_timer += delta
	if is_on_floor() and horizontal_speed() > 0.5:
		if _step_timer >= 0.52:
			_step_timer = 0.0
			_play_step()
	elif not is_on_floor():
		_step_timer = minf(_step_timer, 0.35)  # pre-charge so first landing step fires quickly
	_try_step_up(delta)
	move_and_slide()

## Let the player walk over ledges up to STEP_HEIGHT without stopping.
func _try_step_up(delta: float) -> void:
	if not is_on_floor():
		return
	var motion := Vector3(velocity.x, 0.0, velocity.z) * delta
	if motion.length() < 0.0001:
		return
	# Not blocked at foot level → no step needed.
	if not test_move(global_transform, motion):
		return
	var up := Vector3.UP * STEP_HEIGHT
	# Headroom to lift, and path clear once raised → it's a climbable step, not a wall.
	if test_move(global_transform, up):
		return
	if test_move(global_transform.translated(up), motion):
		return
	global_position += up

func _fly(delta: float) -> void:
	velocity = Vector3.ZERO
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var cam: Camera3D = head.get_node("Camera3D")
	var cam_basis: Basis = cam.global_transform.basis
	var dir: Vector3 = cam_basis * Vector3(input.x, 0.0, input.y)
	if dir.length() > 0.001:
		global_position += dir.normalized() * fly_speed * delta

func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

func set_biome(b: int) -> void:
	current_biome = clampi(b, 0, 6)

func _build_step_audio() -> void:
	_step_player = AudioStreamPlayer.new()
	_step_player.name = "Footsteps"
	add_child(_step_player)
	# Parametric footstep per biome: [sharpness 0..1, body_hz, decay_rate]
	var params := [
		[0.04, 72.0,  22.0],  # 0 offices   — muffled carpet thud
		[0.52, 260.0, 13.0],  # 1 drowned   — wet tile slap
		[0.26, 108.0, 17.0],  # 2 apartments — hollow floor knock
		[0.68, 90.0,  10.0],  # 3 tunnels   — concrete slap + ring
		[0.88, 340.0,  7.0],  # 4 dead mall  — marble click
		[0.74, 86.0,   6.0],  # 5 stairwell  — hard echo
		[0.03, 62.0,  26.0],  # 6 floodlights — soft grass thud
	]
	for p in params:
		_step_sounds.append(_make_step_sound(p[0], p[1], p[2]))

func _make_step_sound(sharpness: float, body_hz: float, decay: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.22)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(body_hz * 97.0 + decay * 13.0)
	for i in count:
		var t := float(i) / float(rate)
		var env := exp(-t * (24.0 + sharpness * 72.0))
		var body := sin(TAU * body_hz * t) * exp(-t * decay) * (1.0 - sharpness * 0.25)
		var click := sin(TAU * 3400.0 * t) * exp(-t * 220.0) * sharpness
		var noise := rng.randf_range(-1.0, 1.0) * exp(-t * (50.0 - sharpness * 40.0)) * maxf(0.0, 1.0 - sharpness) * 0.55
		var s := clampf((env * 0.25 + body * 0.65 + click + noise) * 28000.0, -32767.0, 32767.0)
		data.encode_s16(i * 2, int(s))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav

func _play_step() -> void:
	if _step_sounds.is_empty() or not is_instance_valid(_step_player):
		return
	var idx := clampi(current_biome, 0, _step_sounds.size() - 1)
	_step_player.stream = _step_sounds[idx]
	_step_player.volume_db = -20.0 + randf_range(-2.5, 1.5)
	_step_player.pitch_scale = 0.92 + randf_range(0.0, 0.16)
	_step_player.play()

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

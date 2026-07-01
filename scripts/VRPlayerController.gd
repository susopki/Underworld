class_name VRPlayerController
extends CharacterBody3D

@export var walk_speed := 1.55
@export var acceleration := 5.5
@export var gravity := 18.0
@export var snap_turn_degrees := 35.0
@export var snap_turn_cooldown := 0.32
@export var floor_y := 0.05
@export var stick_deadzone := 0.18
@export var stick_turn_threshold := 0.72
@export var smooth_turn_speed := 0.0

@onready var origin: XROrigin3D = $XROrigin3D
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var left_controller: XRController3D = $XROrigin3D/LeftHand
@onready var right_controller: XRController3D = $XROrigin3D/RightHand

var current_biome := 0
var _turn_timer := 0.0
var _step_timer := 0.0
var _step_player: AudioStreamPlayer
var _step_sounds: Array[AudioStream] = []
var _knocked := false
var _blackout: ColorRect

func _ready() -> void:
	add_to_group("player")
	floor_snap_length = 0.25
	_build_blackout()
	_build_breathing()
	_build_step_audio()

func _physics_process(delta: float) -> void:
	if _knocked:
		velocity = Vector3.ZERO
		return
	_turn_timer = maxf(0.0, _turn_timer - delta)
	_handle_turn(delta)
	var input := _movement_input()
	var forward := -camera.global_transform.basis.z
	var right := camera.global_transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction := (right * input.x + forward * -input.y).normalized()
	var target := direction * walk_speed
	velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target.z, acceleration * delta)
	velocity.y = 0.0 if is_on_floor() else velocity.y - gravity * delta
	_update_steps(delta)
	move_and_slide()

func _movement_input() -> Vector2:
	var keyboard := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var controller := _controller_vector(left_controller, true)
	return controller if controller.length() >= stick_deadzone else keyboard

func _turn_input() -> Vector2:
	return _controller_vector(right_controller, false)

func _controller_vector(controller: XRController3D, left_side: bool) -> Vector2:
	var names := [
		"primary",
		"thumbstick",
		"joystick",
		"trackpad",
		"primary_axis",
		"ax_button",
	]
	for action_name in names:
		var value := _safe_controller_vector(controller, action_name)
		if value.length() >= stick_deadzone:
			return _apply_deadzone(value)
	var joy := _joypad_stick(left_side)
	if joy.length() >= stick_deadzone:
		return _apply_deadzone(joy)
	return Vector2.ZERO

func _safe_controller_vector(controller: XRController3D, action_name: String) -> Vector2:
	if controller == null:
		return Vector2.ZERO
	if not controller.get_is_active():
		return Vector2.ZERO
	return controller.get_vector2(action_name)

func _joypad_stick(left_side: bool) -> Vector2:
	var devices := Input.get_connected_joypads()
	if devices.is_empty():
		return Vector2.ZERO
	var best := Vector2.ZERO
	for device in devices:
		var x := Input.get_joy_axis(device, JOY_AXIS_LEFT_X if left_side else JOY_AXIS_RIGHT_X)
		var y := Input.get_joy_axis(device, JOY_AXIS_LEFT_Y if left_side else JOY_AXIS_RIGHT_Y)
		var value := Vector2(x, y)
		if value.length() > best.length():
			best = value
	return best

func _apply_deadzone(value: Vector2) -> Vector2:
	if value.length() < stick_deadzone:
		return Vector2.ZERO
	var strength := inverse_lerp(stick_deadzone, 1.0, minf(value.length(), 1.0))
	return value.normalized() * strength

func _handle_turn(delta: float) -> void:
	var turn := _turn_input()
	if smooth_turn_speed > 0.0 and absf(turn.x) >= stick_deadzone:
		rotate_y(-turn.x * deg_to_rad(smooth_turn_speed) * delta)
		return
	_handle_snap_turn(turn)

func _handle_snap_turn(turn: Vector2) -> void:
	if _turn_timer > 0.0:
		return
	if absf(turn.x) < stick_turn_threshold:
		return
	rotate_y(deg_to_rad(-snap_turn_degrees * signf(turn.x)))
	_turn_timer = snap_turn_cooldown

func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()

func set_biome(b: int) -> void:
	current_biome = clampi(b, 0, 6)

func knock_down(black_time := 4.0) -> void:
	if _knocked:
		return
	_knocked = true
	velocity = Vector3.ZERO
	var tween := create_tween()
	tween.tween_property(_blackout, "color:a", 0.92, 0.35)
	await get_tree().create_timer(black_time).timeout
	var wake := create_tween()
	wake.tween_property(_blackout, "color:a", 0.0, 1.0)
	await wake.finished
	_knocked = false

func _build_blackout() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 80
	add_child(layer)
	_blackout = ColorRect.new()
	_blackout.color = Color(0, 0, 0, 0)
	_blackout.anchor_right = 1.0
	_blackout.anchor_bottom = 1.0
	_blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_blackout)

func _build_breathing() -> void:
	var player := AudioStreamPlayer.new()
	player.name = "VRBreathing"
	player.volume_db = -28.0
	player.stream = _breath_wave()
	add_child(player)
	player.play()

func _build_step_audio() -> void:
	_step_player = AudioStreamPlayer.new()
	_step_player.name = "VRFootsteps"
	add_child(_step_player)
	var files := [
		"res://audio/step_concrete.ogg",
		"res://audio/step_wet.ogg",
		"res://audio/step_wood.ogg",
		"res://audio/step_concrete.ogg",
		"res://audio/step_concrete.ogg",
		"res://audio/step_concrete.ogg",
		"res://audio/step_grass.ogg",
	]
	for path in files:
		if ResourceLoader.exists(path):
			_step_sounds.append(load(path))
		else:
			_step_sounds.append(_make_step_sound())

func _update_steps(delta: float) -> void:
	_step_timer += delta
	if is_on_floor() and horizontal_speed() > 0.35:
		if _step_timer >= 0.66:
			_step_timer = 0.0
			_play_step()
	else:
		_step_timer = minf(_step_timer, 0.18)

func _play_step() -> void:
	if _step_sounds.is_empty():
		return
	_step_player.stream = _step_sounds[clampi(current_biome, 0, _step_sounds.size() - 1)]
	_step_player.volume_db = -24.0 + randf_range(-2.5, 0.5)
	_step_player.pitch_scale = 0.9 + randf_range(0.0, 0.12)
	_step_player.play()

func _make_step_sound() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 0.16)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17031 + current_biome
	for i in count:
		var t := float(i) / float(rate)
		var hit := rng.randf_range(-1.0, 1.0) * exp(-t * 42.0)
		var low := sin(TAU * 64.0 * t) * exp(-t * 22.0)
		data.encode_s16(i * 2, int(clampf((hit * 0.38 + low * 0.44) * 21000.0, -32767.0, 32767.0)))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav

func _breath_wave() -> AudioStreamWAV:
	var rate := 22050
	var duration := 5.8
	var count := int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 40231
	var filtered := 0.0
	for i in count:
		var t := float(i) / float(rate)
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.035)
		var cycle := sin(TAU * t / duration)
		var inhale := pow(maxf(0.0, cycle), 1.7)
		var exhale := pow(maxf(0.0, -cycle), 1.25)
		var sample := filtered * (inhale * 0.30 + exhale * 0.22) * 13000.0
		bytes.encode_s16(i * 2, int(clampf(sample, -32767.0, 32767.0)))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = count
	wav.data = bytes
	return wav

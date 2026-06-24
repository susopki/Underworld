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
	_flashlight.shadow_enabled = false
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
	var raised := global_transform.translated(up)
	if test_move(raised, motion):
		return
	# Only step up if there's solid ground to land on ahead (avoid climbing walls / stepping into air).
	var forward := raised.translated(motion)
	if not test_move(forward, Vector3.DOWN * (STEP_HEIGHT + 0.06)):
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
	# Per biome: [body_hz, noise_mix 0..1, ring_decay, duration_s]
	# body_hz     — fundamental resonance of the floor material
	# noise_mix   — 1.0 = all filtered noise (carpet/grass), 0.0 = pure resonance (marble)
	# ring_decay  — how fast the resonance fades (high = dull, low = ringy)
	# duration    — total clip length
	var params := [
		[62.0,  0.90, 55.0, 0.18],  # 0 offices   — muffled carpet: almost pure noise, no ring
		[210.0, 0.50, 28.0, 0.22],  # 1 drowned   — wet tile: noise burst + medium resonance
		[88.0,  0.40, 22.0, 0.24],  # 2 apartments — hollow floor: low body with some ring
		[75.0,  0.25, 14.0, 0.26],  # 3 tunnels   — concrete: heavy body, long ring
		[260.0, 0.10,  7.0, 0.30],  # 4 dead mall  — marble: sharp transient, very ringy
		[70.0,  0.18,  6.0, 0.32],  # 5 stairwell  — stone: low body, very long ring
		[52.0,  0.95, 65.0, 0.16],  # 6 floodlights — grass: soft noise burst, no ring
	]
	for p in params:
		_step_sounds.append(_make_step_sound(p[0], p[1], p[2], p[3]))

# Synthesises one footstep impact.
# Layers: initial transient + low-pass-filtered noise burst + multi-harmonic resonance.
func _make_step_sound(body_hz: float, noise_mix: float, ring_decay: float, duration: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * duration)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(body_hz * 113.0 + ring_decay * 17.0)
	# Pre-fill raw noise buffer
	var raw := PackedFloat32Array()
	raw.resize(count)
	for i in count:
		raw[i] = rng.randf_range(-1.0, 1.0)
	# Low-pass filter the noise — cutoff tracks body_hz so carpet stays
	# thuddy and marble stays bright relative to each other.
	var lp := clampf(body_hz * 3.5 / float(rate), 0.015, 0.35)
	var filtered := 0.0
	for i in count:
		var t := float(i) / float(rate)
		filtered = lerpf(filtered, raw[i], lp)
		# Noise burst: loud at impact, decays quickly; carpet keeps it long
		var noise_env := exp(-t * (12.0 + (1.0 - noise_mix) * 55.0))
		var noise_sample := filtered * noise_env * noise_mix
		# Resonance: three harmonics with natural amplitude ratios
		var res_env1 := exp(-t * ring_decay)
		var res_env2 := exp(-t * ring_decay * 2.1)
		var res_env3 := exp(-t * ring_decay * 4.0)
		var res := (sin(TAU * body_hz * t) * res_env1
				  + sin(TAU * body_hz * 2.0 * t) * res_env2 * 0.42
				  + sin(TAU * body_hz * 3.0 * t) * res_env3 * 0.16) * (1.0 - noise_mix * 0.75)
		# Impact transient: ~1 ms broadband click at the very start
		var transient := exp(-t * 900.0) * (0.25 + (1.0 - noise_mix) * 0.55)
		var s := clampf((noise_sample + res + transient) * 26000.0, -32767.0, 32767.0)
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
	_step_player.volume_db = -19.0 + randf_range(-3.0, 1.0)
	_step_player.pitch_scale = 0.93 + randf_range(0.0, 0.14)
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

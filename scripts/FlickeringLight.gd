class_name FlickeringLight
extends OmniLight3D

@export var base_energy := 2.4
@export var random_flicker := true
var forced_time := 0.0
var blackout_time := 0.0
var _next_glitch := 2.0
static var _buzz_stream: AudioStreamWAV
var _buzz: AudioStreamPlayer3D

func _ready() -> void:
	light_energy = base_energy
	_next_glitch = randf_range(1.0, 8.0)
	_buzz = AudioStreamPlayer3D.new()
	_buzz.stream = _get_buzz()
	_buzz.volume_db = -27.0
	_buzz.max_distance = 9.5
	_buzz.unit_size = 3.0
	add_child(_buzz)
	_buzz.play()

static func _get_buzz() -> AudioStreamWAV:
	if _buzz_stream:
		return _buzz_stream
	var rate := 22050
	var count := int(rate * 2.0)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5527
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.6)
		# Mains hum (100 Hz + harmonics) plus faint high-frequency sizzle/crackle.
		var hum := sin(TAU * 100.0 * t) * 0.5 + sin(TAU * 200.0 * t) * 0.2 + sin(TAU * 300.0 * t) * 0.09
		var crackle := filtered * 0.05 * (0.5 + 0.5 * sin(TAU * 7.3 * t))
		data.encode_s16(i * 2, int(clampf((hum + crackle) * 0.6, -1.0, 1.0) * 14000.0))
	_buzz_stream = AudioStreamWAV.new()
	_buzz_stream.format = AudioStreamWAV.FORMAT_16_BITS
	_buzz_stream.mix_rate = rate
	_buzz_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_buzz_stream.loop_end = count
	_buzz_stream.data = data
	return _buzz_stream

func _process(delta: float) -> void:
	_next_glitch -= delta
	forced_time = maxf(0.0, forced_time - delta)
	blackout_time = maxf(0.0, blackout_time - delta)
	if blackout_time > 0.0:
		visible = false
	elif forced_time > 0.0:
		visible = randf() > 0.38
		light_energy = base_energy * randf_range(0.15, 1.2)
	elif random_flicker and _next_glitch <= 0.0:
		visible = randf() > 0.12
		light_energy = base_energy * randf_range(0.65, 1.05)
		_next_glitch = randf_range(3.0, 14.0)
	else:
		visible = true
		light_energy = lerpf(light_energy, base_energy, delta * 5.0)
	if _buzz:
		_buzz.volume_db = -60.0 if blackout_time > 0.0 else (-18.0 if forced_time > 0.0 else -27.0)

func scare_flicker(duration := 3.0) -> void:
	forced_time = duration

func blackout(duration := 3.0) -> void:
	blackout_time = maxf(blackout_time, duration)


class_name RandomSoundManager
extends Node3D

var player: Node3D
var _timer := 8.0
var _rng := RandomNumberGenerator.new()
var _hum_player: AudioStreamPlayer

func _ready() -> void:
	_rng.randomize()
	_start_hum()

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0 and player:
		if _rng.randf() < 0.55:
			play_distant_steps()
		else:
			play_wall_breath()
		_timer = _rng.randf_range(15.0, 34.0)

func play_distant_steps() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_steps(), player.global_position + player.global_transform.basis.z * _rng.randf_range(8.0, 18.0) + Vector3(side * 2.2, 0.3, 0), -10.0)

func play_wall_breath() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_noise(2.8, 0.07, 91), player.global_position + Vector3(side * 2.8, 1.3, -2.0), -13.0)

func _play_3d(stream: AudioStream, where: Vector3, volume: float) -> void:
	var source := AudioStreamPlayer3D.new()
	source.stream = stream
	source.position = where
	source.volume_db = volume
	source.max_distance = 42.0
	source.finished.connect(source.queue_free)
	add_child(source)
	source.play()

func _start_hum() -> void:
	var hum := AudioStreamPlayer.new()
	hum.name = "ElectricalHum"
	hum.stream = _make_hum(50.0)
	hum.volume_db = -28.0
	add_child(hum)
	hum.play()
	_hum_player = hum

func set_biome(biome: int) -> void:
	if not _hum_player:
		return
	_hum_player.stream = _make_hum([50.0, 43.0, 58.0, 36.0][posmod(biome, 4)])
	_hum_player.volume_db = [-28.0, -25.0, -31.0, -22.0][posmod(biome, 4)]
	_hum_player.play()

func _make_hum(base_frequency: float) -> AudioStreamWAV:
	var rate := 22050
	var seconds := 4.0
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / rate
		var value := sin(TAU * base_frequency * t) * 0.42 + sin(TAU * base_frequency * 2.0 * t) * 0.12 + sin(TAU * 2.1 * t) * 0.05
		data.encode_s16(i * 2, int(value * 12000.0))
	return _wav(data, rate, true)

func _make_steps() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 4.3
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	for i in count:
		var t := float(i) / rate
		var phase := fmod(t, 0.78)
		var env := exp(-phase * 18.0) if phase < 0.18 else 0.0
		var value := (sin(TAU * 62.0 * t) + rng.randf_range(-0.35, 0.35)) * env * 0.6
		data.encode_s16(i * 2, int(clamp(value, -1.0, 1.0) * 15000.0))
	return _wav(data, rate, false)

func _make_noise(seconds: float, smooth: float, seed_value: int) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value + _rng.randi()
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), smooth)
		var env := sin(PI * t / seconds)
		data.encode_s16(i * 2, int(filtered * env * 17000.0))
	return _wav(data, rate, false)

func _wav(data: PackedByteArray, rate: int, looped: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	if looped:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = data.size() / 2
	return wav

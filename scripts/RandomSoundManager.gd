class_name RandomSoundManager
extends Node3D

var player: PlayerController
var current_biome := 0
var _timer := 8.0
var _player_step_timer := 0.0
var _rng := RandomNumberGenerator.new()
var _ambience_player: AudioStreamPlayer

func _ready() -> void:
	_rng.randomize()
	_start_ambience()

func _process(delta: float) -> void:
	_update_player_steps(delta)
	_timer -= delta
	if _timer <= 0.0 and player:
		_play_biome_event()
		_timer = _rng.randf_range(15.0, 34.0)

func set_biome(biome: int) -> void:
	current_biome = posmod(biome, 6)
	if not _ambience_player:
		return
	_ambience_player.stream = _make_biome_ambience(current_biome)
	_ambience_player.volume_db = [-28.0, -25.0, -31.0, -22.0, -29.0, -24.0][current_biome]
	_ambience_player.play()

func _start_ambience() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "BiomeAmbience"
	_ambience_player.stream = _make_biome_ambience(0)
	_ambience_player.volume_db = -28.0
	add_child(_ambience_player)
	_ambience_player.play()

func _update_player_steps(delta: float) -> void:
	if not player:
		return
	if player.horizontal_speed() > 0.35 and player.is_on_floor():
		_player_step_timer -= delta
		if _player_step_timer <= 0.0:
			_play_3d(_make_single_step(), player.global_position + Vector3(0, 0.08, 0), -30.0)
			_player_step_timer = 0.58
	else:
		_player_step_timer = minf(_player_step_timer, 0.12)

func _play_biome_event() -> void:
	match current_biome:
		0: # Office: ballast pops and impossible footsteps.
			if _rng.randf() < 0.45: play_electrical_pop()
			elif _rng.randf() < 0.72: play_close_knock()
			else: play_distant_steps()
		1: # Drowned halls: isolated drops in a tiled infinity.
			if _rng.randf() < 0.55: _play_3d(_make_tonal_event(4), _random_distant_position(), -10.0)
			else: play_low_drone(4.0)
		2: # Apartments: knocks and breathing through walls.
			if _rng.randf() < 0.48: play_close_knock()
			else: play_wall_breath(_rng.randf() < 0.35)
		3: # Tunnel: metal movement and ceiling scrape.
			if _rng.randf() < 0.38: play_metal_slam()
			elif _rng.randf() < 0.68: play_ceiling_crawl()
			else: play_ceiling_scrape()
		4: # Mall: voices lost in a huge empty volume.
			if _rng.randf() < 0.38: play_whisper()
			elif _rng.randf() < 0.68: play_phantom_chord()
			else: play_distant_steps()
		5: # Stairwell: scraping above or steps on another flight.
			if _rng.randf() < 0.45: play_ceiling_scrape()
			elif _rng.randf() < 0.72: play_reverse_hit()
			else: play_distant_steps()

func play_distant_steps() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	var where := player.global_position + player.global_transform.basis.z * _rng.randf_range(8.0, 18.0) + Vector3(side * 2.2, 0.3, 0)
	_play_3d(_make_steps(), where, -18.0)

func play_wall_breath(close := false) -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	var distance := 1.35 if close else 2.8
	_play_3d(_make_breath_stack(3.4 if close else 2.8), player.global_position + Vector3(side * distance, 1.3, -1.1), -8.0 if close else -13.0)

func play_metal_slam() -> void:
	_play_3d(_make_tonal_event(0), _random_distant_position(), -5.0)

func play_ceiling_scrape() -> void:
	_play_3d(_make_tonal_event(1), player.global_position + Vector3(randf_range(-3.0, 3.0), 2.9, randf_range(-5.0, 5.0)), -9.0)

func play_whisper() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_tonal_event(2), player.global_position + Vector3(side * 2.4, 1.55, randf_range(-1.5, 1.5)), -16.0)

func play_electrical_pop() -> void:
	_play_3d(_make_tonal_event(3), _random_distant_position(), -8.0)

func play_reverse_hit() -> void:
	_play_3d(_make_reverse_impact(), player.global_position + Vector3(randf_range(-1.6, 1.6), 1.6, randf_range(-2.4, 2.4)), -7.0)

const DREAD_DRONE := "res://audio/dread_drone.ogg"

func play_low_drone(duration := 5.0) -> void:
	if ResourceLoader.exists(DREAD_DRONE):
		_play_3d(load(DREAD_DRONE), _random_distant_position(), -10.0)
	else:
		_play_3d(_make_low_drone(duration), _random_distant_position(), -12.0)

func play_close_knock() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_knock_pattern(), player.global_position + Vector3(side * _rng.randf_range(1.4, 2.4), 1.05, _rng.randf_range(-0.8, 1.6)), -10.0)

func play_ceiling_crawl() -> void:
	_play_3d(_make_ceiling_crawl(), player.global_position + Vector3(randf_range(-2.8, 2.8), 2.9, randf_range(-3.2, 3.2)), -8.0)

func play_phantom_chord() -> void:
	_play_3d(_make_phantom_chord(), _random_distant_position(), -11.0)

func silence_hum(duration := 5.0) -> void:
	if not _ambience_player:
		return
	var previous := _ambience_player.volume_db
	var tween := create_tween()
	tween.tween_property(_ambience_player, "volume_db", -80.0, 0.08)
	tween.tween_interval(duration)
	tween.tween_property(_ambience_player, "volume_db", previous, 1.8)

func _random_distant_position() -> Vector3:
	return player.global_position + Vector3(_rng.randf_range(-12.0, 12.0), _rng.randf_range(0.2, 2.8), _rng.randf_range(-18.0, 18.0))

func _make_biome_ambience(biome: int) -> AudioStreamWAV:
	var rate := 22050
	var seconds := 6.0
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4401 + biome * 977
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.008)
		var value := 0.0
		match biome:
			0:
				value = sin(TAU * 49.0 * t) * 0.42 + sin(TAU * 98.0 * t) * 0.16 + filtered * 0.08
			1:
				value = sin(TAU * 31.0 * t) * 0.24 + filtered * 0.38 + sin(TAU * 0.46 * t) * sin(TAU * 72.0 * t) * 0.12
			2:
				var pipe_ring := exp(-fmod(t, 2.73) * 13.0) * sin(TAU * 410.0 * t)
				value = sin(TAU * 54.0 * t) * 0.18 + sin(TAU * 111.0 * t) * 0.06 + pipe_ring * 0.1 + filtered * 0.12
			3:
				value = sin(TAU * 27.0 * t) * 0.34 + sin(TAU * 41.0 * t) * 0.13 + filtered * (0.3 + sin(TAU * 0.17 * t) * 0.12)
			4:
				value = sin(TAU * 46.0 * t) * 0.13 + sin(TAU * 311.0 * t + sin(t * 0.3)) * 0.035 + filtered * 0.26
			5:
				value = filtered * (0.38 + 0.2 * sin(TAU * 0.21 * t)) + sin(TAU * 83.0 * t) * sin(TAU * 0.12 * t) * 0.1
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 12000.0))
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
		var envelope := _step_pulse(t, 0.78) + _step_pulse(t - 0.19, 0.78) * 0.42 + _step_pulse(t - 0.43, 0.78) * 0.2
		var value := (sin(TAU * 62.0 * t) + rng.randf_range(-0.35, 0.35)) * envelope * 0.6
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 10500.0))
	return _wav(data, rate, false)

func _make_single_step() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 0.92
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	for i in count:
		var t := float(i) / rate
		var envelope := _decay_after(t, 0.0, 24.0) + _decay_after(t, 0.18, 22.0) * 0.32 + _decay_after(t, 0.39, 19.0) * 0.14
		var tone := sin(TAU * (54.0 + current_biome * 4.0) * t)
		var value := (tone * 0.45 + rng.randf_range(-0.24, 0.24)) * envelope * 0.32
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 9000.0))
	return _wav(data, rate, false)

func _step_pulse(time_value: float, period: float) -> float:
	if time_value < 0.0:
		return 0.0
	var phase := fmod(time_value, period)
	return exp(-phase * 18.0) if phase < 0.2 else 0.0

func _decay_after(time_value: float, start: float, decay: float) -> float:
	return exp(-(time_value - start) * decay) if time_value >= start else 0.0

func _make_tonal_event(kind: int) -> AudioStreamWAV:
	var rate := 22050
	var seconds: float = [1.8, 4.8, 3.2, 0.9, 1.7, 2.0][kind]
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		var value := 0.0
		match kind:
			0: value = (sin(TAU * 43.0 * t) * 1.1 + sin(TAU * 61.0 * t) * 0.55 + rng.randf_range(-0.7, 0.7)) * exp(-t * 3.8)
			1:
				filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.025)
				value = filtered * sin(TAU * (150.0 + sin(t * 3.0) * 55.0) * t) * sin(PI * t / seconds)
			2:
				filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.055)
				value = filtered * (0.25 + 0.75 * sin(TAU * 2.7 * t)) * sin(PI * t / seconds) + sin(TAU * 127.0 * t) * 0.08
			3: value = rng.randf_range(-1.0, 1.0) * exp(-t * 22.0) * 0.4 + sin(TAU * 190.0 * t) * exp(-t * 14.0)
			4:
				value = sin(TAU * (210.0 - t * 90.0) * t) * exp(-t * 10.0)
				if t > 0.23: value += sin(TAU * 150.0 * (t - 0.23)) * exp(-(t - 0.23) * 9.0) * 0.45
			5:
				value = sin(TAU * 68.0 * t) * exp(-t * 18.0)
				if t > 0.62: value += sin(TAU * 59.0 * (t - 0.62)) * exp(-(t - 0.62) * 16.0) * 0.58
		data.encode_s16(i * 2, int(clampf(value * 0.78, -1.0, 1.0) * 21000.0))
	return _wav(data, rate, false)

func _make_reverse_impact() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 2.2
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	for i in count:
		var t := float(i) / rate
		var rise := smoothstep(0.0, 1.0, t / 1.45)
		var hit := exp(-abs(t - 1.48) * 24.0)
		var tail := exp(maxf(0.0, t - 1.48) * -2.6)
		var value := sin(TAU * (38.0 + rise * 92.0) * t) * rise * 0.55
		value += rng.randf_range(-1.0, 1.0) * (rise * 0.18 + hit * 0.8) * tail
		value += sin(TAU * 27.0 * t) * hit * 1.1
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 22000.0))
	return _wav(data, rate, false)

func _make_low_drone(seconds: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.01)
		var envelope := sin(PI * t / seconds)
		var value := (sin(TAU * 23.0 * t) * 0.55 + sin(TAU * 31.0 * t + sin(t)) * 0.35 + filtered * 0.24) * envelope
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 19000.0))
	return _wav(data, rate, false)

func _make_knock_pattern() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 2.1
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	var hits: Array[float] = [0.05, 0.31, 0.86, 0.95, 1.54]
	for i in count:
		var t := float(i) / rate
		var envelope := 0.0
		for hit in hits:
			envelope += exp(-abs(t - hit) * 42.0)
		var value := (sin(TAU * 84.0 * t) * 0.72 + rng.randf_range(-0.3, 0.3)) * envelope
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 16000.0))
	return _wav(data, rate, false)

func _make_ceiling_crawl() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 4.0
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = _rng.randi()
	for i in count:
		var t := float(i) / rate
		var scrape: float = abs(sin(TAU * 4.2 * t + sin(t * 3.0))) * 0.45
		var pulse: float = exp(-fmod(t, 0.42) * 16.0)
		var value: float = rng.randf_range(-1.0, 1.0) * scrape * pulse + sin(TAU * 190.0 * t) * pulse * 0.18
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 17000.0))
	return _wav(data, rate, false)

func _make_phantom_chord() -> AudioStreamWAV:
	var rate := 22050
	var seconds := 3.6
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var freqs: Array[float] = [53.0, 58.4, 91.0, 137.0]
	for i in count:
		var t := float(i) / rate
		var envelope := sin(PI * t / seconds)
		var value := 0.0
		for f in freqs:
			value += sin(TAU * (f + sin(t * 0.8) * 1.7) * t) * 0.18
		value *= envelope
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 18000.0))
	return _wav(data, rate, false)

func _make_breath_stack(seconds: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 913 + _rng.randi()
	var filtered := 0.0
	for i in count:
		var t := float(i) / rate
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.055)
		var inhale := pow(maxf(0.0, sin(TAU * 0.42 * t)), 2.0)
		var throat := sin(TAU * 72.0 * t + filtered * 0.3) * 0.16
		var value := filtered * inhale * 0.72 + throat * inhale
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 18500.0))
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
		var envelope := sin(PI * t / seconds)
		data.encode_s16(i * 2, int(filtered * envelope * 17000.0))
	return _wav(data, rate, false)

func _play_3d(stream: AudioStream, where: Vector3, volume: float) -> void:
	var source := AudioStreamPlayer3D.new()
	source.stream = stream
	source.volume_db = volume
	source.max_distance = 42.0
	source.finished.connect(source.queue_free)
	add_child(source)
	source.global_position = where
	source.play()

func _wav(data: PackedByteArray, rate: int, looped: bool) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	if looped:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_end = data.size() / 2
	return wav

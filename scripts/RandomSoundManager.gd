class_name RandomSoundManager
extends Node3D

var player: PlayerController
var current_biome := 0
var _timer := 8.0
var _player_step_timer := 0.0
var _rng := RandomNumberGenerator.new()
var _ambience_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer

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
	if _music_player:
		_music_player.stream = _make_byte_music(current_biome)
		_music_player.play()

func _start_ambience() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "BiomeAmbience"
	_ambience_player.stream = _make_biome_ambience(0)
	_ambience_player.volume_db = -28.0
	add_child(_ambience_player)
	_ambience_player.play()
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "AlmostInaudibleByteMusic"
	_music_player.stream = _make_byte_music(0)
	_music_player.volume_db = -43.0
	add_child(_music_player)
	_music_player.play()

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
			if _rng.randf() < 0.55: play_electrical_pop()
			else: play_distant_steps()
		1: # Drowned halls: isolated drops in a tiled infinity.
			_play_3d(_make_tonal_event(4), _random_distant_position(), -12.0)
		2: # Apartments: knocks and breathing through walls.
			if _rng.randf() < 0.5: _play_3d(_make_tonal_event(5), _random_distant_position(), -9.0)
			else: play_wall_breath()
		3: # Tunnel: metal movement and ceiling scrape.
			if _rng.randf() < 0.5: play_metal_slam()
			else: play_ceiling_scrape()
		4: # Mall: voices lost in a huge empty volume.
			if _rng.randf() < 0.55: play_whisper()
			else: play_distant_steps()
		5: # Stairwell: scraping above or steps on another flight.
			if _rng.randf() < 0.5: play_ceiling_scrape()
			else: play_distant_steps()

func play_distant_steps() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	var where := player.global_position + player.global_transform.basis.z * _rng.randf_range(8.0, 18.0) + Vector3(side * 2.2, 0.3, 0)
	_play_3d(_make_steps(), where, -18.0)

func play_wall_breath() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_noise(2.8, 0.07, 91), player.global_position + Vector3(side * 2.8, 1.3, -2.0), -13.0)

func play_metal_slam() -> void:
	_play_3d(_make_tonal_event(0), _random_distant_position(), -5.0)

func play_ceiling_scrape() -> void:
	_play_3d(_make_tonal_event(1), player.global_position + Vector3(randf_range(-3.0, 3.0), 2.9, randf_range(-5.0, 5.0)), -9.0)

func play_whisper() -> void:
	var side := -1.0 if _rng.randf() < 0.5 else 1.0
	_play_3d(_make_tonal_event(2), player.global_position + Vector3(side * 2.4, 1.55, randf_range(-1.5, 1.5)), -16.0)

func play_electrical_pop() -> void:
	_play_3d(_make_tonal_event(3), _random_distant_position(), -8.0)

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
				var flutter := 0.72 + 0.28 * sin(TAU * 0.37 * t) * sin(TAU * 1.9 * t)
				value = sin(TAU * 50.0 * t) * 0.44 + sin(TAU * 100.0 * t) * 0.15 + sin(TAU * 2360.0 * t) * 0.025 * flutter
			1:
				value = sin(TAU * 34.0 * t) * 0.2 + filtered * 0.34 + sin(TAU * 0.46 * t) * sin(TAU * 72.0 * t) * 0.12
			2:
				var pipe_ring := exp(-fmod(t, 2.73) * 13.0) * sin(TAU * 410.0 * t)
				value = sin(TAU * 58.0 * t) * 0.2 + sin(TAU * 116.0 * t) * 0.06 + pipe_ring * 0.08 + filtered * 0.08
			3:
				value = sin(TAU * 27.0 * t) * 0.34 + sin(TAU * 41.0 * t) * 0.13 + filtered * (0.3 + sin(TAU * 0.17 * t) * 0.12)
			4:
				value = sin(TAU * 46.0 * t) * 0.13 + sin(TAU * 311.0 * t + sin(t * 0.3)) * 0.035 + filtered * 0.26
			5:
				value = filtered * (0.38 + 0.2 * sin(TAU * 0.21 * t)) + sin(TAU * 83.0 * t) * sin(TAU * 0.12 * t) * 0.1
		data.encode_s16(i * 2, int(clampf(value, -1.0, 1.0) * 12000.0))
	return _wav(data, rate, true)

func _make_byte_music(biome: int) -> AudioStreamWAV:
	var rate := 22050
	var seconds := 8.0
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	var notes: Array[int]
	match biome:
		0: notes = [45, 0, 52, 48, 0, 47, 43, 0, 50, 0, 48, 45, 0, 40, 43, 0]
		1: notes = [50, 55, 57, 0, 55, 52, 0, 48, 50, 0, 45, 48, 0, 43, 45, 0]
		2: notes = [41, 0, 44, 48, 47, 0, 44, 40, 0, 39, 43, 46, 0, 43, 39, 0]
		3: notes = [34, 34, 0, 37, 33, 0, 31, 31, 0, 38, 34, 0, 29, 0, 31, 0]
		4: notes = [52, 0, 59, 55, 0, 54, 0, 47, 52, 0, 50, 43, 0, 45, 0, 42]
		_: notes = [38, 0, 45, 41, 0, 36, 43, 0, 35, 0, 42, 38, 0, 33, 0, 30]
	var step_length := seconds / notes.size()
	for i in count:
		var t := float(i) / rate
		var step_index := mini(int(t / step_length), notes.size() - 1)
		var note := notes[step_index]
		var value := 0.0
		if note > 0:
			var frequency := 440.0 * pow(2.0, (note - 69.0) / 12.0)
			var local_phase := fmod(t, step_length) / step_length
			var envelope := smoothstep(0.0, 0.08, local_phase) * (1.0 - smoothstep(0.62, 1.0, local_phase))
			var square := 1.0 if sin(TAU * frequency * t) >= 0.0 else -1.0
			var sub_square := 1.0 if sin(TAU * frequency * 0.5 * t) >= 0.0 else -1.0
			value = (square * 0.72 + sub_square * 0.28) * envelope * 0.22
		data.encode_s16(i * 2, int(value * 9000.0))
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
	var seconds: float = [1.5, 4.2, 2.7, 0.7, 1.4, 1.8][kind]
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
			0: value = (sin(TAU * 47.0 * t) + rng.randf_range(-0.7, 0.7)) * exp(-t * 4.8)
			1:
				filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.025)
				value = filtered * sin(TAU * (620.0 + sin(t * 3.0) * 140.0) * t) * sin(PI * t / seconds)
			2:
				filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), 0.055)
				value = filtered * (0.35 + 0.65 * sin(TAU * 3.7 * t)) * sin(PI * t / seconds)
			3: value = rng.randf_range(-1.0, 1.0) * exp(-t * 18.0) + sin(TAU * 1100.0 * t) * exp(-t * 11.0)
			4:
				value = sin(TAU * (920.0 - t * 380.0) * t) * exp(-t * 14.0)
				if t > 0.23: value += sin(TAU * 690.0 * (t - 0.23)) * exp(-(t - 0.23) * 12.0) * 0.35
			5:
				value = sin(TAU * 74.0 * t) * exp(-t * 22.0)
				if t > 0.62: value += sin(TAU * 68.0 * (t - 0.62)) * exp(-(t - 0.62) * 20.0) * 0.48
		data.encode_s16(i * 2, int(clampf(value * 0.68, -1.0, 1.0) * 19000.0))
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

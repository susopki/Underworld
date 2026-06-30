class_name CeilingRift
extends Area3D

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if triggered or not (body is PlayerController or body is VRPlayerController or body.is_in_group("player")):
		return
	triggered = true
	var audio := AudioStreamPlayer3D.new()
	audio.stream = _make_impact()
	audio.volume_db = -2.0
	audio.max_distance = 38.0
	add_child(audio)
	audio.play()
	for light in get_tree().get_nodes_in_group("liminal_lights"):
		if light is FlickeringLight:
			light.scare_flicker(2.6)
	var atmosphere := get_tree().get_first_node_in_group("atmosphere") as AtmosphereManager
	if atmosphere:
		atmosphere.pulse_anomaly(1.0)

func _make_impact() -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * 2.4)
	var data := PackedByteArray()
	data.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99173
	for i in count:
		var t := float(i) / rate
		var crack := rng.randf_range(-1.0, 1.0) * exp(-t * 8.0)
		var rumble := sin(TAU * (38.0 - t * 5.0) * t) * exp(-t * 1.8)
		var scrape := sin(TAU * 740.0 * t) * exp(-pow((t - 0.42) * 8.0, 2.0))
		var value: float = clampf(crack * 0.8 + rumble * 0.62 + scrape * 0.24, -1.0, 1.0)
		data.encode_s16(i * 2, int(value * 22000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.data = data
	return wav

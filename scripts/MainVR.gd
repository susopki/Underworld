extends Node3D

const VR_WORLD := preload("res://scenes/VRWorld.tscn")

@onready var xr_bootstrap: XRBootstrap = $XRBootstrap

var _world_loaded := false

func _ready() -> void:
	xr_bootstrap.xr_ready.connect(_load_world)
	xr_bootstrap.xr_failed.connect(_load_world_after_failure)

func _load_world() -> void:
	if _world_loaded:
		return
	_world_loaded = true
	var world := VR_WORLD.instantiate()
	add_child(world)

func _load_world_after_failure() -> void:
	# Do not play the full world before XR is ready on headset, but if the
	# runtime refuses to initialize completely, load a minimal world anyway so
	# logcat shows normal scene startup and the app is not stuck in silence.
	_load_world()

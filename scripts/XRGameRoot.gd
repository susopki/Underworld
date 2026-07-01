extends Node3D

const VR_WORLD := preload("res://scenes/VRWorld.tscn")

@onready var start_xr: Node = $StartXR

var _loaded := false

func _ready() -> void:
	start_xr.xr_started.connect(_load_world)
	start_xr.xr_failed.connect(_on_xr_failed)

func _load_world() -> void:
	if _loaded:
		return
	_loaded = true
	print("Underworld loading VR world after XR start.")
	add_child(VR_WORLD.instantiate())

func _on_xr_failed() -> void:
	print("Underworld XR failed; keeping app alive for logcat instead of closing.")

class_name XRBootstrap
extends Node

@export var target_fps := 72
@export var fallback_scene := "res://scenes/Main.tscn"

var xr_interface: XRInterface

func _ready() -> void:
	_configure_mobile_runtime()
	call_deferred("_start_openxr")

func _configure_mobile_runtime() -> void:
	Engine.max_fps = target_fps
	if OS.get_name() == "Android":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _start_openxr() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface == null:
		push_warning("OpenXR interface not found. Running non-XR fallback.")
		return
	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			push_error("OpenXR failed to initialize.")
			return
	get_viewport().use_xr = true
	get_viewport().transparent_bg = false
	print("Underworld Pico/OpenXR session started")

func is_xr_active() -> bool:
	return xr_interface != null and xr_interface.is_initialized() and get_viewport().use_xr

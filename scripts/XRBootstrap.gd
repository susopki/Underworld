class_name XRBootstrap
extends Node

signal xr_ready
signal xr_failed

@export var target_fps := 72
@export var fallback_scene := "res://scenes/Main.tscn"
@export var startup_retry_seconds := 20.0
@export var retry_interval := 0.35

var xr_interface: XRInterface
var _startup_elapsed := 0.0
var _xr_ready := false

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
		push_warning("OpenXR interface not found yet. Retrying.")
		_retry_or_continue()
		return
	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			push_warning("OpenXR initialize failed. Retrying.")
			_retry_or_continue()
			return
	get_viewport().use_xr = true
	get_viewport().transparent_bg = false
	_xr_ready = true
	print("Underworld Pico/OpenXR session started")
	xr_ready.emit()

func _retry_or_continue() -> void:
	_startup_elapsed += retry_interval
	if _startup_elapsed >= startup_retry_seconds:
		push_error("OpenXR did not initialize before timeout.")
		xr_failed.emit()
		return
	get_tree().create_timer(retry_interval).timeout.connect(_start_openxr)

func is_xr_active() -> bool:
	return _xr_ready and xr_interface != null and xr_interface.is_initialized() and get_viewport().use_xr

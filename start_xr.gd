extends Node

signal focus_lost
signal focus_gained
signal pose_recentered
signal xr_started
signal xr_failed

@export var maximum_refresh_rate := 72
@export var retry_seconds := 20.0
@export var retry_interval := 0.35

var xr_interface: OpenXRInterface
var xr_is_focussed := false
var _elapsed := 0.0
var _started := false

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	call_deferred("_try_start_openxr")

func _try_start_openxr() -> void:
	if _started:
		return
	xr_interface = XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr_interface != null and xr_interface.is_initialized():
		_finish_start()
		return

	if xr_interface != null:
		print("Underworld OpenXR found but not initialized; trying initialize().")
		if xr_interface.initialize():
			_finish_start()
			return

	print("Underworld OpenXR not ready. interface=%s initialized=%s" % [
		str(xr_interface),
		str(xr_interface != null and xr_interface.is_initialized()),
	])
	_elapsed += retry_interval
	if _elapsed >= retry_seconds:
		push_error("Underworld OpenXR failed to start after %.1f seconds." % retry_seconds)
		xr_failed.emit()
		return
	get_tree().create_timer(retry_interval).timeout.connect(_try_start_openxr)

func _finish_start() -> void:
	if _started:
		return
	_started = true
	print("Underworld OpenXR started successfully.")
	var viewport := get_viewport()
	viewport.use_xr = true
	viewport.transparent_bg = false
	if RenderingServer.get_rendering_device():
		viewport.vrs_mode = Viewport.VRS_XR
	if not xr_interface.session_begun.is_connected(_on_openxr_session_begun):
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
	xr_started.emit()

func _on_openxr_session_begun() -> void:
	var current_refresh_rate := xr_interface.get_display_refresh_rate()
	if current_refresh_rate <= 0:
		print("OpenXR: no refresh rate reported")
		return
	var new_rate := current_refresh_rate
	var available_rates := xr_interface.get_available_display_refresh_rates()
	for rate in available_rates:
		if rate > new_rate and rate <= maximum_refresh_rate:
			new_rate = rate
	if new_rate != current_refresh_rate:
		print("OpenXR: setting refresh rate to ", str(new_rate))
		xr_interface.set_display_refresh_rate(new_rate)
		current_refresh_rate = new_rate
	Engine.physics_ticks_per_second = int(current_refresh_rate)

func _on_openxr_visible_state() -> void:
	if xr_is_focussed:
		print("OpenXR lost focus")
		xr_is_focussed = false
		emit_signal("focus_lost")

func _on_openxr_focused_state() -> void:
	print("OpenXR gained focus")
	xr_is_focussed = true
	emit_signal("focus_gained")

func _on_openxr_stopping() -> void:
	print("OpenXR is stopping")

func _on_openxr_pose_recentered() -> void:
	emit_signal("pose_recentered")

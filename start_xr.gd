extends Node

signal focus_lost
signal focus_gained
signal pose_recentered

@export var maximum_refresh_rate := 72
@export var quit_if_openxr_missing := true

var xr_interface: OpenXRInterface
var xr_is_focussed := false

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr_interface != null and xr_interface.is_initialized():
		print("Underworld OpenXR instantiated successfully.")
		var viewport := get_viewport()
		viewport.use_xr = true
		viewport.transparent_bg = false
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		if RenderingServer.get_rendering_device():
			viewport.vrs_mode = Viewport.VRS_XR
		xr_interface.session_begun.connect(_on_openxr_session_begun)
		xr_interface.session_visible.connect(_on_openxr_visible_state)
		xr_interface.session_focussed.connect(_on_openxr_focused_state)
		xr_interface.session_stopping.connect(_on_openxr_stopping)
		xr_interface.pose_recentered.connect(_on_openxr_pose_recentered)
		return

	print("Underworld OpenXR not instantiated. interface=%s initialized=%s" % [
		str(xr_interface),
		str(xr_interface != null and xr_interface.is_initialized()),
	])
	if quit_if_openxr_missing:
		get_tree().quit()

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

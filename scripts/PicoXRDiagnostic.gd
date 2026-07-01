extends Node3D

@onready var origin: XROrigin3D = $XROrigin3D
@onready var camera: XRCamera3D = $XROrigin3D/XRCamera3D
@onready var status_label: Label3D = $StatusLabel

var _xr: XRInterface
var _seconds := 0.0

func _ready() -> void:
	Engine.max_fps = 72
	if OS.get_name() == "Android":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	_log("android boot")
	_start_xr()

func _process(delta: float) -> void:
	_seconds += delta
	$Spinner.rotate_y(delta * 1.8)
	if _xr != null:
		status_label.text = "UNDERWORLD XR DIAG\nOpenXR initialized: %s\nViewport XR: %s\nTime: %.1f" % [
			str(_xr.is_initialized()),
			str(get_viewport().use_xr),
			_seconds,
		]
	else:
		status_label.text = "UNDERWORLD XR DIAG\nOpenXR interface: null\nTime: %.1f" % _seconds

func _start_xr() -> void:
	_xr = XRServer.find_interface("OpenXR")
	if _xr == null:
		_log("OpenXR interface not found")
		status_label.text = "OpenXR interface not found"
		return
	_log("OpenXR interface found initialized=%s" % str(_xr.is_initialized()))
	if not _xr.is_initialized():
		var ok := _xr.initialize()
		_log("OpenXR initialize returned %s" % str(ok))
		if not ok:
			status_label.text = "OpenXR initialize failed"
			return
	get_viewport().use_xr = true
	get_viewport().transparent_bg = false
	_log("viewport use_xr=%s" % str(get_viewport().use_xr))

func _log(message: String) -> void:
	print("[Underworld XR Diag] %s" % message)
	var file := FileAccess.open("user://underworld_xr_diag.txt", FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open("user://underworld_xr_diag.txt", FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line("%s %.3f %s" % [Time.get_datetime_string_from_system(), Time.get_ticks_msec() / 1000.0, message])

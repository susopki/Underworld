extends CanvasLayer
## In-game developer console. Toggle with the ` (backtick / grave) key.
## Commands:
##   noclip          — toggle player collision + free flight
##   tp <level>      — switch to biome 0..6 (or by name) and respawn player
##   help            — list commands

const BIOME_NAMES := ["offices", "drownedhalls", "apartments", "tunnels", "deadmall", "stairwell", "floodlights"]

var _output: RichTextLabel
var _entry: LineEdit

func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()

func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.anchor_right = 1.0
	panel.offset_bottom = 240.0
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	_output = RichTextLabel.new()
	_output.scroll_following = true
	_output.custom_minimum_size = Vector2(0, 200)
	_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_output.bbcode_enabled = true
	_output.text = "[color=#888]Dev console — type 'help'. Toggle with ` .[/color]"
	box.add_child(_output)
	_entry = LineEdit.new()
	_entry.placeholder_text = "command..."
	_entry.text_submitted.connect(_on_submit)
	box.add_child(_entry)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Match the grave/backtick key across layouts (keycode, physical, unicode) + F1 fallback.
		if event.physical_keycode == KEY_QUOTELEFT or event.keycode == KEY_QUOTELEFT \
				or event.unicode == 96 or event.unicode == 126 or event.keycode == KEY_F1:
			_toggle()
			get_viewport().set_input_as_handled()

func _toggle() -> void:
	visible = not visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_entry.clear()
		_entry.grab_focus()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_submit(text: String) -> void:
	_entry.clear()
	var line := text.strip_edges()
	if line.is_empty():
		return
	_print("[color=#6cf]> %s[/color]" % line)
	var parts := line.split(" ", false)
	var cmd := parts[0].to_lower()
	var arg := parts[1] if parts.size() > 1 else ""
	match cmd:
		"noclip": _cmd_noclip()
		"tp": _cmd_tp(arg)
		"help": _print("noclip — toggle clipping\ntp <0-6|name> — jump to biome (%s)" % ", ".join(BIOME_NAMES))
		_: _print("[color=#f66]unknown command: %s[/color]" % cmd)

func _cmd_noclip() -> void:
	var player := _find("PlayerController")
	if player == null:
		_print("[color=#f66]no player in scene[/color]")
		return
	player.set_noclip(not player.noclip)
	_print("noclip: %s" % ("ON" if player.noclip else "OFF"))

func _cmd_tp(arg: String) -> void:
	if arg.is_empty():
		_print("[color=#f66]usage: tp <0-6 | name>[/color]")
		return
	var level := -1
	if arg.is_valid_int():
		level = int(arg)
	else:
		level = BIOME_NAMES.find(arg.to_lower())
	if level < 0 or level > 6:
		_print("[color=#f66]bad level '%s' (0-6 or: %s)[/color]" % [arg, ", ".join(BIOME_NAMES)])
		return
	var gen := _find("LevelGenerator")
	if gen == null:
		_print("[color=#f66]no LevelGenerator in scene[/color]")
		return
	gen._perform_switch(level)
	_print("tp -> %d (%s)" % [level, BIOME_NAMES[level]])

func _find(node_class: String) -> Node:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	return _find_by_class(scene, node_class)

func _find_by_class(node: Node, node_class: String) -> Node:
	if node.is_class(node_class) or (node.get_script() and node.get_script().get_global_name() == node_class):
		return node
	for child in node.get_children():
		var found := _find_by_class(child, node_class)
		if found:
			return found
	return null

func _print(msg: String) -> void:
	_output.text += "\n" + msg

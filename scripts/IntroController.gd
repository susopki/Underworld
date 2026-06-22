extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var prompt: Label = $Interface/Prompt
@onready var title: Label = $Interface/Title
@onready var post_rect: ColorRect = $PostProcess/Monochrome
@onready var entrance_light: OmniLight3D = $EntranceLight

var can_continue := false
var leaving := false
var elapsed := 0.0
var ui_fading := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	prompt.modulate.a = 0.0
	title.modulate.a = 0.0
	var approach := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	approach.tween_property(camera, "position:z", -4.7, 9.0)
	var reveal := create_tween()
	reveal.tween_interval(0.65)
	reveal.tween_property(title, "modulate:a", 0.78, 1.5)
	reveal.tween_interval(1.0)
	reveal.tween_property(prompt, "modulate:a", 1.0, 0.8)
	reveal.tween_callback(_enable_continue)

func _enable_continue() -> void:
	can_continue = true

func _input(event: InputEvent) -> void:
	if not can_continue or leaving:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			_start_game()

func _process(delta: float) -> void:
	elapsed += delta
	var distance_to_portal: float = absf(camera.position.z + 9.86)
	var portal_proximity: float = clampf(1.0 - distance_to_portal / 14.0, 0.0, 1.0)
	(post_rect.material as ShaderMaterial).set_shader_parameter("proximity", portal_proximity)
	if can_continue and not leaving and not ui_fading:
		prompt.modulate.a = 0.58 + sin(elapsed * 2.5) * 0.35
	if camera.position.z < -0.5 and not ui_fading:
		ui_fading = true
		var hide_ui := create_tween().set_parallel(true)
		hide_ui.tween_property(title, "modulate:a", 0.0, 1.15)
		hide_ui.tween_property(prompt, "modulate:a", 0.0, 1.15)
	entrance_light.light_energy = 1.4 + sin(elapsed * 13.0) * 0.18
	if randf() < delta * 0.8:
		entrance_light.visible = not entrance_light.visible
		get_tree().create_timer(randf_range(0.025, 0.1)).timeout.connect(func(): entrance_light.visible = true)

func _start_game() -> void:
	leaving = true
	can_continue = false
	prompt.visible = false
	title.visible = false
	var material := post_rect.material as ShaderMaterial
	var transition := create_tween().set_parallel(true)
	transition.tween_method(func(value: float): material.set_shader_parameter("fade", value), 0.0, 1.0, 0.9)
	transition.tween_property(camera, "position:z", -8.2, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	transition.chain().tween_callback(func(): get_tree().change_scene_to_file("res://scenes/Main.tscn"))

class_name PhantomDoor
extends Node3D

var target: Node3D
var life := 22.0

func _ready() -> void:
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0, 0, 0)
	black.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_add_box(Vector3(1.7, 2.65, 0.08), Vector3(0, 1.32, 0), black)
	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color(0.12, 0.105, 0.085)
	_add_box(Vector3(0.12, 2.85, 0.16), Vector3(-0.93, 1.4, 0), frame)
	_add_box(Vector3(0.12, 2.85, 0.16), Vector3(0.93, 1.4, 0), frame)
	_add_box(Vector3(1.98, 0.12, 0.16), Vector3(0, 2.8, 0), frame)

func _process(delta: float) -> void:
	life -= delta
	if not target or life <= 0.0 or global_position.distance_to(target.global_position) < 5.5:
		var tween := create_tween()
		tween.tween_property(self, "scale:x", 0.0, 0.08)
		tween.tween_callback(queue_free)
		set_process(false)

func _add_box(size: Vector3, pos: Vector3, material: Material) -> void:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	node.mesh = mesh
	node.position = pos
	add_child(node)


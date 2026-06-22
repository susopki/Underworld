class_name LevelPortal
extends Area3D

signal portal_entered(target_level: int)
@export var target_level := 0
var active := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if active and body is PlayerController:
		active = false
		portal_entered.emit(target_level)


extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/Main.tscn") as PackedScene
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var manager := scene.get_node("ScareEventManager") as ScareEventManager
	for event_id in ScareEventManager.EVENT_COUNT:
		manager._run_event(event_id)
		await process_frame
	print("Fear director: %d events executed" % ScareEventManager.EVENT_COUNT)
	quit()

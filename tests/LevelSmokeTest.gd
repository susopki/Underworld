extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/Main.tscn") as PackedScene
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var generator := scene.get_node("LevelGenerator") as LevelGenerator
	for biome in 4:
		if biome > 0:
			generator._perform_switch(biome)
			await process_frame
			await process_frame
		var rooms: Array[Node] = generator.generated_root.get_children().filter(func(node: Node): return node is RoomModule)
		var portals: Array[Node] = generator.generated_root.get_children().filter(func(node: Node): return node is LevelPortal)
		assert(rooms.size() == generator.room_count, "Biome %d has an invalid room count" % biome)
		assert(portals.size() >= 2, "Biome %d has no transition doors" % biome)
		print("Biome %d: %d rooms, %d portals" % [biome, rooms.size(), portals.size()])
	quit()

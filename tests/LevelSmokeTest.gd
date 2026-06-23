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
	for biome in 6:
		if biome > 0:
			generator._perform_switch(biome)
			await process_frame
			await process_frame
		var rooms: Array[Node] = generator.generated_root.get_children().filter(func(node: Node): return node is RoomModule)
		var portals: Array[Node] = generator.generated_root.get_children().filter(func(node: Node): return node is LevelPortal)
		assert(rooms.size() == generator.room_count, "Biome %d has an invalid room count" % biome)
		assert(portals.size() == 1, "Biome %d must contain exactly one rare transition door" % biome)
		var reachable := _reachable_count(generator)
		assert(reachable == generator.room_count, "Biome %d contains disconnected rooms" % biome)
		print("Biome %d: %d connected rooms, %d portal" % [biome, reachable, portals.size()])
	quit()

func _reachable_count(generator: LevelGenerator) -> int:
	var visited := {Vector2i.ZERO: true}
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for direction in directions:
			var neighbor := cell + direction
			if generator.occupied.has(neighbor) and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	return visited.size()

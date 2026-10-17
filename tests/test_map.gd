extends RefCounted
const World = preload("res://scripts/simulation/world.gd")

func reachable(world: PandemicWorld, start: String) -> int:
	var visited: Array = [start]
	var queue: Array = [start]
	while not queue.is_empty():
		var current = queue.pop_front()
		for edge in world.connections:
			if not world.route_is_open(edge): continue
			var next = edge[1] if edge[0] == current else (edge[0] if edge[1] == current else "")
			if next != "" and next not in visited:
				visited.append(next)
				queue.append(next)
	return visited.size()

func run(tree: SceneTree, check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	check.call(data.regions.size() == 24 and data.connections.size() == 38, "Carte livrée : 24 régions et 38 routes")
	var duplicate = data.duplicate(true)
	duplicate.regions[1].position = duplicate.regions[0].position.duplicate()
	check.call(not World.validate_data(duplicate).is_empty(), "Positions dupliquées refusées")
	var world = World.new()
	world.start("boreale")
	for region in world.regions:
		check.call(reachable(world, region.id) == 24, "Réseau standard connexe depuis " + region.id)
	world.start("boreale", 2042, null, null, "degel2042")
	check.call(world.connections.size() == 39 and reachable(world, "boreale") == 24, "Dégel : 39 routes et carte joignable par la sortie initiale")
	# Each starting region must have an observed legal winning strategy in hard mode.
	for region in data.regions:
		var won = false
		for policy in [["discretion", "transmission", "mobility"], ["transmission", "discretion", "mobility"], ["transmission", "mobility", "discretion"]]:
			world.start(region.id, 2042, null, null, "standard", "hard")
			for i in range(500):
				for id in policy:
					if id not in world.purchased:
						world.purchase(id)
						break
				world.step()
				if not world.outcome.is_empty(): break
			if world.outcome == "victory":
				won = true
				break
		check.call(won, "Victoire avec achats légaux en difficile depuis " + region.id)
	var original_size = tree.root.size
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.start_game()
	for resolution in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		tree.root.size = resolution
		await tree.process_frame
		await tree.process_frame
		var bounds = Rect2(Vector2.ZERO, scene.map_view.size)
		var contained = true
		var separated = true
		var targets = true
		var buttons = scene.map_view.buttons
		for i in range(buttons.size()):
			var rect = buttons[i].get_rect()
			contained = contained and bounds.encloses(rect)
			targets = targets and rect.size.y >= 44 and rect.size.x >= 44
			for j in range(i + 1, buttons.size()):
				separated = separated and not rect.intersects(buttons[j].get_rect())
		check.call(contained, "24 régions dans les limites à " + str(resolution))
		check.call(separated, "Aucune zone de clic superposée à " + str(resolution))
		check.call(targets, "Cibles de carte lisibles et de hauteur 44 px à " + str(resolution))
	scene.queue_free()
	tree.root.size = original_size
	await tree.process_frame

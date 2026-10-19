extends SceneTree
## End-of-game summary at the three native resolutions.
## Run with a real renderer: Godot --path . --script res://tests/capture_result.gd
const ORDERS = {"mobility": ["transmission", "mobility", "discretion"], "none": [], "many": ["transmission", "relay", "cohesion", "focus", "mobility", "network", "retention", "discretion", "polar", "seasonal"]}

func _initialize() -> void: call_deferred("run")

func play(scene, order: Array) -> void:
	for day in range(400):
		for id in order:
			if id not in scene.world.purchased and scene.world.evolutions.has(id):
				scene.world.purchase(id)
				break
		scene.world.step()
		if not scene.world.outcome.is_empty(): return

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["victory","defeat-cure","degel-objective","fragile-network","enriched-many"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			var order = ORDERS.mobility
			match state:
				"defeat-cure": order = ORDERS.none
				"degel-objective":
					scene.scenario_id = "degel2042"
					scene.objective_id = "arctic_relays"
				"fragile-network":
					scene.scenario_id = "fragile2042"
					scene.start_id = "centrale"
					scene.reactive_mode = true
					order = ["transmission", "relay", "cohesion", "focus"]
				"enriched-many":
					scene.scenario_id = "degel2042"
					scene.advanced_mode = true
					order = ORDERS.many
			scene.start_game()
			play(scene, order)
			scene.show_result()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/result-%s-%d.png" % [state,dimensions.x]) != OK:
				printerr("Capture impossible : %s %s" % [state, dimensions])
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

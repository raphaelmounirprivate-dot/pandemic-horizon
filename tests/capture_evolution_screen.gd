extends SceneTree
## Évolution screen and its entry point on the map, at the three native resolutions.
## Run with a real renderer: Godot --path . --script res://tests/capture_evolution_screen.gd
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["game","classic","degel-diffusion","degel-resilience","fragile-discretion","exclusive","tutorial"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.training_directory = "user://capture-training"
			if state.begins_with("degel") or state == "exclusive":
				scene.scenario_id = "degel2042"
				scene.advanced_mode = true
			if state == "fragile-discretion":
				scene.scenario_id = "fragile2042"
				scene.start_id = "centrale"
				scene.crises_mode = true
			if state == "tutorial": scene.start_tutorial()
			else: scene.start_game()
			if state != "tutorial":
				for day in range(40):
					for id in ["transmission","mobility","relay","polar"]:
						if id not in scene.world.purchased and scene.world.evolutions.has(id):
							scene.world.purchase(id)
							break
					scene.world.step()
			if state == "exclusive":
				scene.world.points += 20
				scene.world.purchase("air_bridge")
			scene.show_game()
			match state:
				"classic": scene.open_evolution("mobility")
				"degel-diffusion": scene.open_evolution("network")
				"degel-resilience": scene.open_evolution("seasonal")
				"fragile-discretion": scene.open_evolution("timing")
				"exclusive": scene.open_evolution("land_network")
				"tutorial":
					scene.tutorial.stage = 2
					scene.show_game()
					scene.open_evolution()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/evolution-%s-%d.png" % [state,dimensions.x]) != OK:
				printerr("Capture impossible : %s %s" % [state, dimensions])
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

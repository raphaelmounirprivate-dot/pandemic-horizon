extends SceneTree
## Crises and Réseaux fragiles: options step, Évolution screen, local incident, reload.
## Run with a real renderer: Godot --path . --script res://tests/capture_crises.gd
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["menu-classic","menu-crises","menu-fragile","skills","incident","fragile","loaded"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.crises_mode = state != "menu-classic"
			scene.scenario_id = "fragile2042" if state in ["menu-fragile","fragile"] else "degel2042"
			scene.decision_enabled = scene.scenario_id == "degel2042"
			scene.objective_id = "arctic_relays" if scene.scenario_id == "degel2042" else ""
			# The options step applies the option dependencies and the scenario's forced start.
			scene.show_new_game(2)
			if not state.begins_with("menu"):
				scene.start_game()
				if scene.world.regions.is_empty():
					printerr("Démarrage refusé : %s %s" % [state, resolution])
					quit(1)
					return
				for i in range(28 if state == "skills" else 43):
					if state != "skills":
						for id in ["transmission","mobility","backup_links"]:
							if id not in scene.world.purchased:
								scene.world.purchase(id)
								break
					scene.world.step()
				if state == "loaded":
					var loaded = scene.save_store.decode(scene.save_store.encode(scene.world))
					if not loaded.error.is_empty():
						printerr(loaded.error)
						quit(1)
						return
					scene.world = loaded.world
				scene.show_game()
				scene.open_evolution("backup_links")
				if state == "incident": scene.open_overview()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/crises-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

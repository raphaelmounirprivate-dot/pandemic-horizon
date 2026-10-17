extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["menu-classic","menu-enriched","standard","degel","prerequisite","available","loaded-classic","loaded-enriched"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.advanced_mode = state not in ["menu-classic","loaded-classic"]
			scene.scenario_id = "standard" if state == "standard" else "degel2042"
			scene.objective_id = "first_relays" if state == "standard" else "arctic_relays"
			scene.decision_enabled = state != "standard"
			if state.begins_with("menu"): scene.show_menu()
			else:
				scene.start_game()
				for i in range(60 if state == "available" else 28):
					if state == "available":
						for id in ["transmission","mobility","relay"]:
							if id not in scene.world.purchased:
								scene.world.purchase(id)
								break
					scene.world.step()
				if state.begins_with("loaded"):
					var loaded = scene.save_store.decode(scene.save_store.encode(scene.world))
					if not loaded.error.is_empty():
						printerr(loaded.error)
						quit(1)
						return
					scene.world = loaded.world
				scene.show_game()
				if state == "prerequisite": scene.select_evolution("retention")
				if state == "available": scene.select_evolution("network")
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/expanded-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

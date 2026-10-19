extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["classic","enriched","exclusive","resilience","menu","settings","overview","classic-goal","pending"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			if state not in ["classic","classic-goal"]:
				scene.crises_mode = true
				scene.reactive_mode = true
				scene.scenario_id = "degel2042"
				scene.objective_id = "arctic_relays"
				scene.decision_enabled = true
			if state == "classic-goal":
				scene.scenario_id = "degel2042"
				scene.objective_id = "arctic_relays"
			scene.start_game()
			for day in range(28 if state == "pending" else (45 if state == "classic-goal" else 40)):
				for id in ["transmission","mobility","land_network"]:
					if id not in scene.world.purchased:
						scene.world.purchase(id)
						break
				scene.world.step()
			if state == "exclusive": scene.world.purchase("land_network")
			scene.show_game()
			scene.open_evolution("backup_links" if state == "pending" else "regional_reserves" if state == "resilience" else ("air_bridge" if state == "exclusive" else "discretion"))
			if state == "menu": scene.show_menu()
			if state == "settings": scene.show_settings()
			if state == "overview": scene.open_overview()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/skills-%s-%d.png" % [state,dimensions.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

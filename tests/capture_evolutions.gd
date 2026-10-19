extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["insufficient","prerequisite","available","acquired","excluded","pending","arctic","tutorial"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.scenario_id = "degel2042"
			scene.decision_enabled = state in ["pending","arctic"]
			scene.objective_id = "arctic_relays" if state == "arctic" else ""
			scene.start_game()
			if state in ["available","acquired","excluded","pending","arctic"]:
				for i in range(28 if state in ["pending","arctic"] else 45): scene.world.step()
				if state not in ["pending","arctic"]:
					scene.world.purchase("transmission")
					scene.world.purchase("mobility")
				if state == "excluded": scene.world.purchase("sea_logistics")
			if state == "tutorial":
				scene.start_tutorial()
				scene.tutorial.ready = true
				scene.next_lesson()
				scene.tutorial.ready = true
				scene.next_lesson()
			scene.show_game()
			scene.open_evolution("mobility" if state == "prerequisite" else ("air_bridge" if state in ["available","excluded"] else "transmission"))
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/evolution-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

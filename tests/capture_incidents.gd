extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["none","pending","storm","earthquake","communications","favorable","focused","overview"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.crises_mode = true
			scene.scenario_id = "degel2042"
			scene.objective_id = "arctic_relays"
			scene.decision_enabled = true
			scene.start_game()
			var incident = {}
			if state == "pending":
				for day in range(28): scene.world.step()
			elif state != "none":
				incident = scene.world.event_definitions.filter(func(e): return e.get("template") == ("regional_recovery" if state == "favorable" else ("earthquake" if state == "focused" else ("communications" if state == "overview" else state))))[0]
				for day in range(incident.start_day): scene.world.step()
			scene.show_game()
			await process_frame
			if state == "focused": scene.map_view.focus_incident(incident.id)
			if state == "overview": scene.open_overview()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/incidents-%s-%d.png" % [state,dimensions.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

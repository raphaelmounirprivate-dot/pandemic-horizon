extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["settings","help-large","overview-large","reduced-game"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			scene.settings_path = "user://capture-no-preferences.cfg"
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.reading_large = true
			scene.reduced_motion = true
			if state == "settings": scene.show_settings()
			elif state == "help-large": scene.open_help()
			else:
				scene.advanced_mode = true
				scene.scenario_id = "degel2042"
				scene.start_game()
				for day in range(60):
					for id in ["transmission","mobility","relay"]:
						if id not in scene.world.purchased:
							scene.world.purchase(id)
							break
					scene.world.step()
				scene.show_game()
				if state == "overview-large": scene.open_overview()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/comfort-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

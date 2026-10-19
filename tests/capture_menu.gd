extends SceneTree
## Title screen and the three "Nouvelle partie" steps at the three native resolutions.
## Run with a real renderer: Godot --path . --script res://tests/capture_menu.gd
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["title","title-resume","scenario","options","options-degel","start","start-locked"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			match state:
				"title": scene.show_menu()
				"title-resume":
					scene.start_game()
					scene.show_menu()
				"scenario": scene.show_new_game(1)
				"options": scene.show_new_game(2)
				"options-degel":
					scene.scenario_id = "degel2042"
					scene.reactive_mode = true
					scene.objective_id = "arctic_relays"
					scene.show_new_game(2)
				"start":
					scene.start_id = "centrale"
					scene.show_new_game(3)
				"start-locked":
					scene.scenario_id = "degel2042"
					scene.show_new_game(3)
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/menu-%s-%d.png" % [state,dimensions.x]) != OK:
				printerr("Capture impossible : %s %s" % [state, dimensions])
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review/strategy")
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		var scene = load("res://scenes/main.tscn").instantiate()
		root.add_child(scene)
		scene.set_process(false)
		scene.autosave_enabled = false
		scene.agent_id = "pulse"
		for state in ["setup", "decision", "result"]:
			if state == "setup": scene.show_new_game(2)
			elif state == "decision":
				scene.start_game()
				for day in range(20): scene.world.step()
				scene.show_game()
			else:
				for day in range(400):
					if scene.world.Strategy.pending(scene.world): scene.world.Strategy.choose(scene.world, "anchor")
					for id in ["transmission", "relay", "discretion", "mobility"]:
						if id not in scene.world.purchased:
							scene.world.purchase(id)
							break
					scene.world.step()
					if not scene.world.outcome.is_empty(): break
				scene.show_result()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/strategy/%s-%d.png" % [state, dimensions.x]) != OK:
				printerr("Capture stratégique impossible.")
				quit(1)
				return
		scene.queue_free()
		await process_frame
	quit()

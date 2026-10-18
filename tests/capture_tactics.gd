extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for dimensions in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(dimensions)
		for state in ["menu","pending","active","fragile"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.reactive_mode = true
			scene.scenario_id = "fragile2042" if state in ["menu","fragile"] else "degel2042"
			scene.start_id = "centrale" if scene.scenario_id == "fragile2042" else "boreale"
			if state == "menu": scene.show_menu()
			else:
				scene.start_game()
				while not scene.World.Tactics.pending(scene.world) and scene.world.outcome.is_empty():
					for id in ["transmission","mobility","discretion"]:
						if id not in scene.world.purchased:
							scene.world.purchase(id)
							break
					scene.world.step()
				if state == "active":
					scene.World.Tactics.choose(scene.world,"opportunity")
					scene.world.step()
				if state == "fragile":
					scene.World.Tactics.choose(scene.world,"endure")
					for day in range(8): scene.world.step()
				scene.show_game()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != dimensions or shot.save_png("res://.impeccable/review/tactics-%s-%d.png" % [state,dimensions.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

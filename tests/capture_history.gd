extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["start","ongoing","pending","victory","defeat","legacy"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.scenario_id = "degel2042"
			scene.difficulty_id = "hard" if state == "defeat" else "normal"
			scene.objective_id = "arctic_relays"
			scene.decision_enabled = true
			scene.start_game()
			for i in range(0 if state == "start" else (28 if state == "pending" else (45 if state in ["ongoing","legacy"] else 800))):
				if state in ["victory","ongoing","legacy"]:
					for id in ["transmission","mobility","discretion"]:
						if id not in scene.world.purchased:
							scene.world.purchase(id)
							break
				scene.world.step()
				if not scene.world.outcome.is_empty(): break
			if state == "legacy":
				var data = scene.save_store.encode(scene.world)
				data.erase("history")
				data.erase("purchase_history")
				scene.world = scene.save_store.decode(data).world
			if state == "victory" and scene.world.outcome != "victory" or state == "defeat" and not scene.world.outcome.begins_with("defeat"):
				printerr("Résultat inattendu pour capture "+state)
				quit(1)
				return
			if scene.world.outcome.is_empty(): scene.show_game()
			else: scene.show_result()
			scene.open_overview()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/history-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		for state in ["pending","all","land","air","sea","zoom","motion"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.scenario_id = "degel2042"
			scene.decision_enabled = true
			scene.start_game()
			for i in range(28 if state == "pending" else 70):
				for id in ["transmission","mobility","discretion","polar"]:
					if id not in scene.world.purchased:
						scene.world.purchase(id)
						break
				scene.world.step()
			scene.show_game()
			await process_frame
			await process_frame
			if state in ["land","air","sea"]: scene.map_view.set_flow_filter(state)
			if state == "zoom": scene.map_view.zoom_at(scene.map_view.size*.5,2)
			if state == "motion": scene.map_view.visual_time = 1.2
			await process_frame
			await RenderingServer.frame_post_draw
			var shot = root.get_texture().get_image()
			if shot.get_size() != resolution or shot.save_png("res://.impeccable/review/transport-%s-%d.png" % [state,resolution.x]) != OK:
				quit(1)
				return
			scene.queue_free()
			await process_frame
	quit()

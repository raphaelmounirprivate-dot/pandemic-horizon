extends SceneTree
## Scoped rendered capture batch; synthetic game decisions, no player saves.
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for resolution in [Vector2i(1280,720), Vector2i(1920,1080)]:
		DisplayServer.window_set_size(resolution)
		for surface in ["menu-off", "menu-on", "degel", "progress", "success", "failed", "result-success", "result-failed", "legacy08"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.save_store.directory = "user://capture-objectives"
			scene.objective_id = "first_relays"
			match surface:
				"menu-off":
					scene.objective_id = ""
					scene.show_menu()
				"menu-on": scene.show_menu()
				"degel":
					scene.scenario_id = "degel2042"
					scene.show_menu()
				"legacy08":
					var decoded = scene.save_store.decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save-0.8-standard.json")))
					scene.world = decoded.world
					scene.show_game()
				_:
					scene.start_game()
					for i in range(35 if surface == "progress" else 60):
						if surface not in ["failed", "result-failed"]:
							for id in ["transmission", "mobility", "discretion"]:
								if id not in scene.world.purchased:
									scene.world.purchase(id)
									break
						scene.world.step()
					if surface.begins_with("result"):
						for i in range(500): scene.world.step()
						scene.show_result()
					else: scene._refresh()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var path = "res://.impeccable/review/objectives-%s-%d.png" % [surface,resolution.x]
			if root.get_texture().get_image().save_png(path) != OK:
				printerr("Capture impossible : " + path)
				quit(1)
				return
			print(path)
			scene.queue_free()
			await process_frame
	quit()

extends SceneTree
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080)]:
		DisplayServer.window_set_size(resolution)
		for surface in ["menu-off","menu-on","waiting","orient","centrale","progress","success","failed","result-success","result-failed","help"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.scenario_id = "degel2042"
			scene.objective_id = "arctic_relays" if surface != "menu-off" else ""
			if surface.begins_with("menu"):
				scene.show_menu()
			else:
				scene.start_game()
				var day = {"waiting":35,"orient":36,"centrale":39,"progress":41}.get(surface,55)
				for i in range(day):
					if surface not in ["failed","result-failed"]:
						for id in ["transmission","mobility","discretion"]:
							if id not in scene.world.purchased:
								scene.world.purchase(id)
								break
					scene.world.step()
				if surface.begins_with("result"):
					for i in range(500): scene.world.step()
					scene.show_result()
				elif surface == "help":
					scene.help_topic = 2
					scene.show_help()
				else: scene._refresh()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var path = "res://.impeccable/review/arctic-%s-%d.png" % [surface,resolution.x]
			if root.get_texture().get_image().save_png(path) != OK:
				printerr("Capture impossible : " + path)
				quit(1)
				return
			print(path)
			scene.queue_free()
			await process_frame
	quit()

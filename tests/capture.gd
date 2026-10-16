extends SceneTree
## Run with a real renderer, not --headless. Screenshots stay outside Git.

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.save_store.directory = "user://capture-saves"
	scene.training_directory = "user://capture-training"
	scene.set_process(false)
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	for resolution in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		if scene.tutorial != null: scene.finish_tutorial()
		scene.world = scene.World.new()
		for slot in scene.SaveStore.SLOTS:
			for suffix in ["", ".bak", ".tmp", ".bak.tmp"]:
				if FileAccess.file_exists(scene.save_store._path(slot) + suffix): DirAccess.remove_absolute(scene.save_store._path(slot) + suffix)
		DisplayServer.window_set_size(resolution)
		for surface in ["menu", "saves-empty", "degel-menu", "game", "help", "isolation", "opening", "instability", "mobilization", "saves-filled", "save-confirm", "result", "menu-resume", "tutorial-1", "tutorial-2", "tutorial-3", "tutorial-4", "tutorial-5", "tutorial-6", "tutorial-saves"]:
			match surface:
				"help":
					scene.open_help()
				"menu-resume":
					scene.start_game()
					scene.show_menu()
				"tutorial-1":
					scene.start_tutorial()
				"tutorial-2":
					scene.toggle_pause()
					scene.advance_time(0.5)
					scene.next_lesson()
				"tutorial-3":
					scene.select_region(2)
					scene.next_lesson()
				"tutorial-4":
					scene.buy_evolution("transmission")
					scene.next_lesson()
				"tutorial-5":
					scene.select_region(0)
					scene.next_lesson()
					scene.toggle_pause()
					scene.advance_time(20)
				"tutorial-6":
					scene.toggle_pause()
					scene.advance_time(20)
					scene.next_lesson()
				"tutorial-saves":
					scene.open_saves()
				"saves-empty":
					scene.open_saves()
				"saves-filled":
					scene.save_store.save_slot("slot1", scene.world)
					scene.save_store.save_slot("auto", scene.world)
					scene.open_saves()
				"save-confirm":
					scene.confirm_action("Remplacer l'emplacement 1 par la partie en mémoire ?", func(): pass)
				"menu":
					scene.scenario_id = "standard"
					scene.difficulty_id = "normal"
					scene.show_menu()
				"degel-menu":
					scene.scenario_id = "degel2042"
					scene.difficulty_id = "hard"
					scene.show_menu()
				"game":
					scene.scenario_id = "standard"
					scene.difficulty_id = "normal"
					scene.start_game()
					for i in range(40): scene.world.step()
					scene._refresh()
				"isolation", "opening", "instability", "mobilization":
					scene.scenario_id = "degel2042"
					scene.difficulty_id = "normal"
					scene.start_game()
					var target_day = {"isolation":0,"opening":12,"instability":33,"mobilization":56}[surface]
					for i in range(target_day): scene.world.step()
					scene._refresh()
				"result":
					if is_instance_valid(scene.pending_dialog):
						scene.pending_dialog.queue_free()
					for i in range(500): scene.world.step()
					scene.show_result()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var image = root.get_texture().get_image()
			var path = "res://build/qa/%s-%d.png" % [surface, resolution.x]
			if image.save_png(path) != OK:
				printerr("Capture impossible : " + path)
				quit(1)
				return
			print("Capture : " + path)
	scene.queue_free()
	await process_frame
	quit()

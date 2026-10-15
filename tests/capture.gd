extends SceneTree
## Run with a real renderer, not --headless. Screenshots stay outside Git.

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	DirAccess.make_dir_recursive_absolute("res://build/qa")
	for resolution in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
		DisplayServer.window_set_size(resolution)
		for surface in ["menu", "game", "settings", "result"]:
			match surface:
				"menu": scene.show_menu()
				"game":
					scene.start_game()
					for i in range(40): scene.world.step()
					scene._refresh()
				"settings": scene.show_settings()
				"result":
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

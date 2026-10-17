extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		DisplayServer.window_set_size(resolution)
		var scene = load("res://scenes/main.tscn").instantiate()
		root.add_child(scene)
		scene.set_process(false)
		scene.autosave_enabled = false
		scene.scenario_id = "degel2042"
		scene.decision_enabled = true
		scene.objective_id = "arctic_relays"
		scene.start_game()
		for i in range(28): scene.world.step()
		scene.show_game()
		await process_frame
		await process_frame
		for state in ["world","zoom","edge","keyboard","reset"]:
			var map = scene.map_view
			if state == "zoom": map.zoom_at(map.map_position(scene.world.regions[0]),2.5)
			if state == "edge": map.move_camera(Vector2(-9999,-9999))
			if state == "keyboard": map.buttons[0].grab_focus()
			if state == "reset": map.reset_view()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var path = "res://.impeccable/review/camera-%s-%d.png" % [state,resolution.x]
			var image = root.get_texture().get_image()
			if image.get_size() != resolution:
				printerr("Capture de taille incorrecte : %s au lieu de %s" % [image.get_size(),resolution])
				quit(1)
				return
			if image.save_png(path) != OK:
				quit(1)
				return
			print(path)
		scene.queue_free()
		await process_frame
	quit()

extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	DisplayServer.window_set_size(Vector2i(1280,720))
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	scene.scenario_id = "degel2042"
	scene.start_game()
	for day in range(70):
		for id in ["transmission","mobility","discretion","polar"]:
			if id not in scene.world.purchased:
				scene.world.purchase(id)
				break
		scene.world.step()
	scene._refresh()
	scene.map_view.motion_enabled = true
	for i in range(45): await process_frame
	var samples: Array = []
	for i in range(120):
		var start = Time.get_ticks_usec()
		await RenderingServer.frame_post_draw
		samples.append((Time.get_ticks_usec()-start)/1000.0)
		await process_frame
	samples.sort()
	var report = {"resolution":"1280x720","scenario":"degel2042","seed":2042,"day":scene.world.day,"frames":samples.size(),"median_frame_ms":samples[60],"p95_frame_ms":samples[114],"renderer":RenderingServer.get_video_adapter_name()}
	print("MAP_BENCHMARK: " + JSON.stringify(report))
	var suffix = "after" if "--after" in OS.get_cmdline_user_args() else "before"
	var file = FileAccess.open("res://build/qa/map-benchmark-%s.json" % suffix,FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	scene.queue_free()
	await process_frame
	quit()

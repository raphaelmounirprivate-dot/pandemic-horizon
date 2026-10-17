extends SceneTree
const Store = preload("res://scripts/persistence/save_store.gd")
func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://.impeccable/review")
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080)]:
		DisplayServer.window_set_size(resolution)
		for surface in ["menu-off","menu-on","scheduled","pending","insufficient","support","limit","neutral","expired","timeout","help","legacy-pending","legacy-active","legacy-help"]:
			var scene = load("res://scenes/main.tscn").instantiate()
			root.add_child(scene)
			scene.set_process(false)
			scene.autosave_enabled = false
			scene.scenario_id = "degel2042"
			scene.objective_id = "arctic_relays"
			scene.decision_enabled = surface != "menu-off"
			if surface.begins_with("menu"):
				scene.show_menu()
			elif surface.begins_with("legacy"):
				var name = "active" if surface == "legacy-active" else "pending"
				scene.world = Store.new().decode(JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/save-0.11-%s.json" % name))).world
				if surface == "legacy-help":
					scene.help_topic = 9
					scene.show_help()
				else: scene.show_decision()
			else:
				scene.start_game()
				for i in range(28 if surface != "scheduled" else 0): scene.world.step()
				if surface == "insufficient":
					scene.world.purchase("transmission")
					scene.world.purchase("mobility")
				if surface in ["pending","insufficient"]: scene.show_decision()
				elif surface == "help":
					scene.help_topic = 9
					scene.show_help()
				else:
					if surface in ["support","limit","neutral","expired"]:
						scene.world.Decisions.choose(scene.world,"observe" if surface == "neutral" else ("support" if surface == "expired" else surface))
						for i in range(13 if surface == "expired" else 6): scene.world.step()
					elif surface == "timeout":
						for i in range(3): scene.world.step()
						scene.show_decision()
					if surface != "timeout": scene._refresh()
			await process_frame
			await process_frame
			await RenderingServer.frame_post_draw
			var path = "res://.impeccable/review/decisions-%s-%d.png" % [surface,resolution.x]
			if root.get_texture().get_image().save_png(path) != OK:
				printerr("Capture impossible : " + path)
				quit(1)
				return
			print(path)
			scene.queue_free()
			await process_frame
	quit()

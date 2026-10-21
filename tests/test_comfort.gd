extends RefCounted
func run(tree: SceneTree, check: Callable) -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	scene.settings_path = "user://test-comfort.cfg"
	if FileAccess.file_exists(scene.settings_path): DirAccess.remove_absolute(scene.settings_path)
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	check.call(not scene.sounds_enabled and not scene.reduced_motion and not scene.reading_large,"Confort facultatif par défaut")
	var original_size = tree.root.size
	for resolution in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2395,1060)]:
		tree.root.size = resolution
		scene.show_settings()
		await tree.process_frame
		await tree.process_frame
		for key in ["motion","reading","sound"]:
			var toggle = scene.body.get_node(key)
			check.call(Rect2(Vector2.ZERO,Vector2(resolution)).encloses(toggle.get_global_rect()) and toggle.size.y >= 44,"Réglage visible et cible44px : "+key)
			toggle.grab_focus()
			var press = InputEventKey.new()
			press.keycode = KEY_ENTER
			press.pressed = true
			tree.root.push_input(press)
			press = press.duplicate()
			press.pressed = false
			tree.root.push_input(press)
			await tree.process_frame
			check.call(toggle.button_pressed,"Réglage activé au clavier : "+key)
		scene.body.get_node("audio_volume/volume").value = 0.6
		var saved = ConfigFile.new()
		saved.load(scene.settings_path)
		check.call(saved.get_value("comfort","reduced_motion") == true and saved.get_value("comfort","reading_large") == true and saved.get_value("audio","enabled") == true and is_equal_approx(saved.get_value("audio","volume"),0.6),"Préférences enregistrées ensemble")
		scene.reduced_motion = false
		scene.reading_large = false
		scene.sounds_enabled = false
		scene._load_preferences()
		check.call(scene.reduced_motion and scene.reading_large and scene.sounds_enabled and is_equal_approx(scene.sound_volume,0.6),"Préférences relues")
		scene.advanced_mode = true
		scene.scenario_id = "degel2042"
		scene.start_game()
		scene.paused = false
		scene._refresh()
		var model = scene.World.new()
		model.start("boreale",2042,null,null,"degel2042","normal",null,null,"",false,true)
		var clock = scene.map_view.visual_time
		for i in range(35):
			scene.advance_time(0.5)
			model.step()
		var actual = scene.save_store.encode(scene.world)
		var expected = scene.save_store.encode(model)
		actual.erase("saved_at")
		expected.erase("saved_at")
		check.call(actual == expected,"Confort sans effet sur règles, hasard et historique")
		scene.map_view._process(0.1)
		check.call(not scene.map_view.motion_enabled and scene.map_view.visual_time == clock and scene.world.day == 35,"Mouvement réduit figé, simulation poursuivie")
		scene.reduced_motion = false
		scene._refresh()
		scene.map_view._process(0.1)
		check.call(scene.map_view.visual_time > clock,"Mouvement réactivable")
		scene.show_overview()
		await tree.process_frame
		check.call(scene.reading_large and scene.history_chart.get_global_rect().end.y < resolution.y,"Bilan agrandi accessible")
		scene.open_help()
		check.call(scene.help_text.get_theme_font_size("normal_font_size") == 24,"Texte aide agrandi")
		scene.reduced_motion = false
		scene.reading_large = false
		scene.sounds_enabled = false
		scene._save_preferences()
	check.call(scene.feedback.cues.size() == 4 and scene.feedback.cues.purchase.data.size() == 3308,"Quatre sons originaux embarqués")
	scene.feedback.configure(true,0)
	scene.feedback.play_cue("purchase")
	check.call(not scene.feedback.player.playing,"Volume nul coupe le son")
	scene.feedback.configure(false,0.5)
	scene.feedback.play_cue("alert")
	check.call(not scene.feedback.player.playing,"Sons désactivés silencieux")
	# A different writer's settings survive later updates.
	var config = ConfigFile.new()
	config.load(scene.settings_path)
	config.set_value("other","preserved",42)
	config.save(scene.settings_path)
	scene._save_preferences()
	config.load(scene.settings_path)
	check.call(config.get_value("other","preserved") == 42,"Réglage inconnu conservé")
	DirAccess.remove_absolute(scene.settings_path)
	scene.queue_free()
	await tree.process_frame
	tree.root.size = original_size

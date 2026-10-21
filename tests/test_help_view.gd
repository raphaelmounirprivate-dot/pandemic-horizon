extends RefCounted
## F1 help: topics as buttons (no drop-down list), current topic written, 44 px targets.
const Help = preload("res://scripts/ui/help.gd")

func dropdown(node: Node) -> bool:
	if node is OptionButton or node is PopupMenu: return true
	for child in node.get_children():
		if dropdown(child): return true
	return false

func run(tree: SceneTree, check: Callable) -> void:
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2395, 1060)]:
		tree.root.size = dimensions
		var area = Rect2(Vector2.ZERO, Vector2(dimensions))
		for origin in ["menu", "game"]:
			if origin == "menu": scene.show_menu()
			else: scene.start_game()
			scene.open_help()
			await tree.process_frame
			await tree.process_frame
			check.call(scene.screen == "help" and not dropdown(scene.body), "Aide sans liste déroulante à %d depuis %s" % [dimensions.x, origin])
			check.call(scene.help_buttons.size() == Help.TITLES.size(), "Un bouton par sujet d'aide à %d" % dimensions.x)
			var ok = true
			for button in scene.help_buttons:
				ok = ok and button.size.y >= 44 and area.encloses(button.get_global_rect())
			check.call(ok, "Sujets d'aide : cibles ≥ 44 px dans la fenêtre à %d depuis %s" % [dimensions.x, origin])
			check.call(scene.help_buttons[0].has_focus() and scene.help_buttons[0].text.begins_with("● "), "Premier sujet ciblé et marqué en toutes lettres à %d" % dimensions.x)
			scene.close_help()
	tree.root.size = Vector2i(1280, 720)
	scene.start_game()
	scene.open_help()
	await tree.process_frame
	await tree.process_frame
	await inputs.click(tree, scene.help_buttons[8])
	check.call(scene.help_topic == 8 and scene.help_text.text == Help.text_for(8, scene.world, scene.selected), "Clic sur Transports : texte du sujet affiché")
	check.call(scene.help_buttons[8].text == "● " + Help.TITLES[8] and scene.help_buttons[0].text == Help.TITLES[0], "Seul le sujet affiché porte la marque écrite")
	check.call("Sujet affiché" in scene.help_buttons[8].tooltip_text and not "Sujet affiché" in scene.help_buttons[1].tooltip_text, "Infobulle : sujet affiché nommé")
	scene.select_help_topic(99)
	check.call(scene.help_topic == Help.TITLES.size() - 1, "Sujet hors limites ramené au dernier")
	check.call(scene.paused and scene.world.day == 0, "Aide en pause, monde inchangé")
	await inputs.key(tree, KEY_F1)
	check.call(scene.screen == "game" and scene.paused, "F1 referme l'aide vers la partie en pause")
	scene.queue_free()
	await tree.process_frame

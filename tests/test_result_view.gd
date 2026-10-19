extends RefCounted
## Illustrated end-of-game summary.
const World = preload("res://scripts/simulation/world.gd")
const ResultView = preload("res://scripts/ui/result_view.gd")

func play(world, order: Array) -> void:
	for day in range(400):
		for id in order:
			if id not in world.purchased and world.evolutions.has(id):
				world.purchase(id)
				break
		world.step()
		if not world.outcome.is_empty(): return

func targets_ok(node: Node, area: Rect2) -> bool:
	var ok = true
	for child in node.get_children():
		if child is BaseButton and child.is_visible_in_tree():
			ok = ok and child.size.y >= 44 and area.encloses(child.get_global_rect())
		ok = ok and targets_ok(child, area)
	return ok

func run(tree: SceneTree, check: Callable) -> void:
	# Key moments are read from the journal only: bounded, ordered, outcome last.
	for setup in [[{"start": "boreale"}, ["transmission", "mobility", "discretion"]], [{"start": "boreale"}, []], [{"start": "boreale", "scenario": "degel2042", "expanded": true}, ["transmission", "relay", "cohesion", "focus", "mobility", "network", "retention", "discretion", "polar", "seasonal"]], [{"start": "centrale", "scenario": "fragile2042", "crises": true, "reactive": true}, ["transmission", "relay"]]]:
		var world = World.new()
		check.call(world.start_with(setup[0]).is_empty(), "Partie de bilan : " + JSON.stringify(setup[0]))
		var journal_before = world.journal.duplicate()
		play(world, setup[1])
		var state = JSON.stringify(world.regions) + str(world.day) + str(world.cure)
		var moments = ResultView.key_moments(world)
		check.call(not world.outcome.is_empty() and moments.size() <= ResultView.MAX_MOMENTS, "Moments clés bornés : " + JSON.stringify(setup[0]))
		check.call(moments[-1] == world.journal[-1].replace("Jour ", "J"), "Issue en dernier moment clé")
		check.call(moments.all(func(line): return not line.begins_with("J0 ")), "Aucun moment du jour 0")
		for line in moments:
			for part in line.split(" · "):
				if part.ends_with("régions atteintes sur %d" % world.regions.size()):
					check.call(int(part.split(" ")[0]) <= world.regions.size(), "Régions atteintes comptées une seule fois : " + part)
		if not setup[1].is_empty(): check.call(moments[0].contains("Évolution acquise : Diffusion") or moments.any(func(line): return line.contains("Diffusion")), "Premier achat parmi les moments clés")
		check.call(state == JSON.stringify(world.regions) + str(world.day) + str(world.cure) and world.journal.size() >= journal_before.size(), "Lecture des moments sans modifier la partie")
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2395, 1060)]:
		tree.root.size = dimensions
		var area = Rect2(Vector2.ZERO, Vector2(dimensions))
		for setup in [["standard", ["transmission", "mobility", "discretion"], "victory"], ["standard", [], "defeat_cure"], ["degel2042", ["transmission", "relay", "cohesion", "focus", "mobility", "network", "retention", "discretion", "polar", "seasonal"], ""]]:
			scene.scenario_id = setup[0]
			scene.start_id = "boreale"
			scene.advanced_mode = setup[0] == "degel2042"
			scene.crises_mode = false
			scene.reactive_mode = false
			scene.objective_id = ""
			scene.decision_enabled = false
			scene.start_game()
			play(scene.world, setup[1])
			if not setup[2].is_empty(): check.call(scene.world.outcome == setup[2], "Issue attendue : " + setup[2])
			scene.show_result()
			await tree.process_frame
			await tree.process_frame
			var world = scene.world
			var label = "%s %d" % [world.outcome, dimensions.x]
			check.call(scene.screen == "result" and scene.body.get_child(0).get_child(0).text == ("Victoire" if world.outcome == "victory" else "Défaite"), "Titre d'issue : " + label)
			check.call(scene.result_cards.size() == 4 and scene.result_cards.day.value_label.text == "Jour %d" % world.day and scene.result_cards.score.value_label.text == str(world.score()), "Cartes jour et score exactes : " + label)
			check.call(scene.result_cards.touched.value_label.text == "%.1f %%" % (world.coverage() * 100) and scene.result_cards.touched.meter.visible and is_equal_approx(scene.result_cards.touched.meter.target, 0.9), "Carte couverture avec repère 90 % : " + label)
			check.call(scene.result_cards.cure.value_label.text == "%.1f %%" % world.cure and is_equal_approx(scene.result_cards.cure.meter.value, clampf(world.cure / 100.0, 0, 1)), "Carte remède exacte : " + label)
			check.call(scene.history_chart.target_line and area.encloses(scene.history_chart.get_global_rect()), "Courbe avec objectif visible : " + label)
			check.call(scene.result_moments.get_line_count() <= scene.result_moments.get_visible_line_count() and area.encloses(scene.result_moments.get_global_rect()), "Tous les moments clés visibles : " + label)
			check.call(targets_ok(scene.body, area), "Boutons du bilan ≥ 44 px dans la fenêtre : " + label)
			var focused = scene.get_viewport().gui_get_focus_owner()
			check.call(focused is Button and focused.text == "Rejouer avec les mêmes choix", "Rejouer ciblé : " + label)
	scene.open_overview()
	check.call(scene.screen == "overview", "Monde accessible depuis le bilan")
	scene.close_overview()
	check.call(scene.screen == "result", "Retour de Monde au bilan")
	scene.show_new_game(1)
	check.call(scene.screen == "setup", "Nouvelle partie depuis le bilan")
	scene.show_result()
	scene.restart_game()
	check.call(scene.screen == "game" and scene.world.day == 0, "Rejouer depuis le bilan")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280, 720)

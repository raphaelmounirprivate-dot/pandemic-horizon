extends RefCounted
## Title screen and the three-step "Nouvelle partie" flow.

func dropdown(node: Node) -> bool:
	if node is OptionButton or node is PopupMenu: return true
	for child in node.get_children():
		if dropdown(child): return true
	return false

func targets_ok(node: Node, area: Rect2) -> bool:
	var ok = true
	for child in node.get_children():
		if child is BaseButton and child.is_visible_in_tree():
			ok = ok and child.size.y >= 44 and area.encloses(child.get_global_rect())
		ok = ok and targets_ok(child, area)
	return ok

func run(tree: SceneTree, check: Callable) -> void:
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2395, 1060)]:
		tree.root.size = dimensions
		var area = Rect2(Vector2.ZERO, Vector2(dimensions))
		for setup in [["standard", false, false], ["degel2042", true, true], ["fragile2042", false, true]]:
			scene.scenario_id = setup[0]
			scene.reactive_mode = setup[1]
			scene.objective_id = ""
			scene.decision_enabled = setup[0] == "degel2042"
			scene.show_menu()
			await tree.process_frame
			check.call(not dropdown(scene.body) and targets_ok(scene.body, area), "Écran titre sans liste déroulante, cibles ≥ 44 px dans la fenêtre à %d" % dimensions.x)
			for step in [1, 2, 3]:
				scene.show_new_game(step)
				await tree.process_frame
				await tree.process_frame
				check.call(scene.screen == "setup" and scene.setup_step == step, "Étape %d ouverte" % step)
				check.call(not dropdown(scene.body), "Étape %d sans liste déroulante : %s" % [step, setup[0]])
				check.call(targets_ok(scene.body, area), "Étape %d : cibles ≥ 44 px dans la fenêtre à %d : %s" % [step, dimensions.x, setup[0]])
				check.call(scene.setup_next.has_focus() and area.encloses(scene.setup_next.get_global_rect()), "Étape %d : Suivant ciblé et visible" % step)
	tree.root.size = Vector2i(1280, 720)
	# Step 1: one card per scenario, the chosen one says so in words.
	scene.reactive_mode = false
	scene.crises_mode = false
	scene.advanced_mode = false
	scene.scenario_id = "standard"
	scene.show_new_game(1)
	check.call(scene.scenario_cards.size() == 3 and scene.scenario_cards.standard.chosen and scene.scenario_cards.standard.state_label.text == "Choisi" and scene.scenario_cards.degel2042.state_label.text == "Choisir", "Trois cartes de scénario, choix écrit")
	check.call("Départ libre" in scene.scenario_cards.standard.body_label.text and "Boréale" in scene.scenario_cards.degel2042.body_label.text, "Cartes : départ libre ou imposé nommé")
	scene.choose_scenario("fragile2042")
	check.call(scene.crises_mode and scene.advanced_mode and scene.start_locked and scene.start_id == "centrale", "Réseaux fragiles active les aléas et impose Centrale")
	check.call(scene.scenario_cards.fragile2042.has_focus() and "Aléas" in scene.setup_summary.text, "Choix gardé en focus, résumé mis à jour")
	scene.show_new_game(2)
	check.call(scene.crises_choice.disabled and scene.crises_choice.button_pressed and scene.advanced_choice.disabled, "Options verrouillées par le scénario")
	scene.choose_scenario("standard")
	scene.crises_mode = false
	scene.advanced_mode = false
	# Step 2: difficulty cards and grouped options.
	scene.show_new_game(2)
	check.call(scene.difficulty_cards.size() == 3 and scene.difficulty_cards.normal.chosen, "Trois cartes de difficulté, Normale choisie")
	check.call("Remède plus rapide" in scene.difficulty_cards.hard.body_label.text and "1.30" in scene.difficulty_cards.hard.body_label.text, "Difficulté expliquée en mots et en chiffres")
	scene.choose_difficulty("easy")
	check.call(scene.difficulty_id == "easy" and scene.difficulty_cards.easy.chosen and not scene.difficulty_cards.normal.chosen and "Facile" in scene.setup_summary.text, "Choix de difficulté immédiat")
	await tree.process_frame
	await tree.process_frame
	await inputs.click(tree, scene.objective_choice)
	check.call(scene.objective_id == "first_relays" and "Objectif facultatif" in scene.setup_summary.text, "Objectif facultatif au clic")
	check.call(not scene.decision_choice.visible, "Décision réservée à Dégel")
	# Step 3: start picked on the map; a forced start ignores clicks.
	scene.show_new_game(3)
	await tree.process_frame
	await tree.process_frame
	await inputs.click(tree, scene.start_map.buttons[4])
	var picked = scene.start_map.world.regions[4]
	check.call(scene.start_id == picked.id and picked.name in scene.start_detail.text and scene.start_map.selected == 4, "Départ choisi sur la carte")
	scene.choose_scenario("degel2042")
	scene.show_new_game(3)
	await tree.process_frame
	await tree.process_frame
	await inputs.click(tree, scene.start_map.buttons[2])
	check.call(scene.start_id == "boreale" and "imposé" in scene.start_detail.text, "Départ imposé : clic sans effet, raison écrite")
	# Navigation: pills, Retour, Échap and F1 come back to the same step.
	await inputs.key(tree, KEY_ESCAPE)
	check.call(scene.screen == "setup" and scene.setup_step == 2, "Échap recule d'une étape")
	await inputs.key(tree, KEY_F1)
	await inputs.key(tree, KEY_F1)
	check.call(scene.screen == "setup" and scene.setup_step == 2, "L'aide revient à l'étape en cours")
	scene.setup_back()
	scene.setup_back()
	check.call(scene.screen == "menu", "Retour depuis l'étape 1 : écran titre")
	scene.show_new_game(3)
	scene.setup_forward()
	check.call(scene.screen == "game" and scene.world.scenario.id == "degel2042" and scene.world.difficulty.id == "easy" and scene.world.start_region_id == "boreale", "Lancer applique les choix des trois étapes")
	scene.show_menu()
	await tree.process_frame
	var focused = scene.get_viewport().gui_get_focus_owner()
	check.call(focused is Button and focused.text == "Reprendre la partie", "Écran titre : Reprendre ciblé quand une partie existe")
	scene.queue_free()
	await tree.process_frame

extends RefCounted
## Dedicated Évolution screen: layout, tabs, pause, keyboard and purchase.
const World = preload("res://scripts/simulation/world.gd")
const TreeView = preload("res://scripts/ui/skill_tree_view.gd")
const EvolutionView = preload("res://scripts/ui/evolution_view.gd")

func run(tree: SceneTree, check: Callable) -> void:
	# Pure layout: children sit one column right of their in-family parent, cells never collide.
	for options in [{"start": "boreale"}, {"start": "boreale", "scenario": "degel2042", "expanded": true}, {"start": "centrale", "scenario": "fragile2042", "crises": true}]:
		var model = World.new()
		check.call(model.start_with(options).is_empty(), "Partie pour la disposition : " + JSON.stringify(options))
		var skills = load("res://scripts/ui/skill_presenter.gd")
		for family in skills.catalog():
			var ids = family.skills.filter(func(id): return model.evolutions.has(id))
			if ids.is_empty(): continue
			var cells = TreeView.layout(model, ids)
			check.call(cells.size() == ids.size(), "Chaque compétence a une case : %s" % family.id)
			var seen: Array = []
			var aligned = true
			for id in ids:
				aligned = aligned and cells[id] not in seen
				seen.append(cells[id])
				for required in model.evolutions[id].requires:
					if required in ids: aligned = aligned and cells[id].x == cells[required].x + 1
			check.call(aligned, "Arbre de gauche à droite sans case partagée : %s" % family.id)
	var inputs = load("res://tests/input_journey.gd").new()
	var scene = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(scene)
	scene.set_process(false)
	scene.autosave_enabled = false
	for dimensions in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2395, 1060)]:
		tree.root.size = dimensions
		var area = Rect2(Vector2.ZERO, Vector2(dimensions))
		for setup in [["degel2042", "boreale", false], ["fragile2042", "centrale", true]]:
			scene.scenario_id = setup[0]
			scene.start_id = setup[1]
			scene.advanced_mode = true
			scene.crises_mode = setup[2]
			scene.reactive_mode = false
			scene.objective_id = ""
			scene.decision_enabled = false
			scene.start_game()
			for day in range(30): scene.world.step()
			scene.show_game()
			await tree.process_frame
			check.call(area.encloses(scene.evolution_open_button.get_global_rect()) and scene.evolution_open_button.size.y >= 44, "Bouton Évolution visible à %d" % dimensions.x)
			for group in EvolutionView.families(scene):
				scene.open_evolution(group.skills[0])
				await tree.process_frame
				await tree.process_frame
				check.call(scene.screen == "evolution" and scene.evolution_family == group.id and scene.evolution_tabs[group.id].button_pressed, "Onglet %s actif à %d" % [group.id, dimensions.x])
				check.call(scene.evolution_buttons.size() == group.skills.size(), "Onglet %s : toutes ses compétences" % group.id)
				var rects: Array = []
				var clean = true
				for id in scene.evolution_buttons:
					var rect: Rect2 = scene.evolution_buttons[id].get_global_rect()
					clean = clean and area.encloses(rect) and scene.evolution_tree.get_global_rect().encloses(rect) and rect.size.y >= 44
					for other in rects: clean = clean and not rect.intersects(other)
					rects.append(rect)
				check.call(clean, "Nœuds dans la fenêtre, sans chevauchement, ≥ 44 px : %s %s %d" % [setup[0], group.id, dimensions.x])
				check.call(area.encloses(scene.evolution_purchase.get_global_rect()) and area.encloses(scene.evolution_back.get_global_rect()), "Achat et retour visibles : %s %s %d" % [setup[0], group.id, dimensions.x])
				check.call(scene.evolution_tabs.values().all(func(tab): return area.encloses(tab.get_global_rect()) and tab.size.y >= 44), "Onglets visibles et ciblables à %d" % dimensions.x)
			scene.close_evolution()
	# Pause is restored on return; time never advances on the Évolution screen.
	tree.root.size = Vector2i(1280, 720)
	scene.scenario_id = "standard"
	scene.start_id = "boreale"
	scene.advanced_mode = false
	scene.crises_mode = false
	scene.start_game()
	scene.paused = false
	scene.open_evolution()
	var day = scene.world.day
	scene.advance_time(5.0)
	check.call(scene.screen == "evolution" and scene.paused and scene.world.day == day, "Écran Évolution en pause, sans avancer le temps")
	scene.close_evolution()
	check.call(scene.screen == "game" and not scene.paused, "Retour à la carte : la partie reprend comme avant")
	scene.paused = true
	scene.open_evolution()
	scene.close_evolution()
	check.call(scene.paused, "Retour à la carte : une partie en pause reste en pause")
	# Keyboard: E opens and closes, Échap returns to the map, F1 comes back to the screen.
	await inputs.key(tree, KEY_E)
	check.call(scene.screen == "evolution", "E ouvre l'écran Évolution")
	await inputs.key(tree, KEY_F1)
	check.call(scene.screen == "help", "F1 ouvre l'aide depuis l'écran Évolution")
	await inputs.key(tree, KEY_F1)
	check.call(scene.screen == "evolution", "Fermer l'aide ramène à l'écran Évolution")
	await inputs.key(tree, KEY_E)
	check.call(scene.screen == "game", "E referme l'écran Évolution")
	await inputs.key(tree, KEY_E)
	await inputs.key(tree, KEY_ESCAPE)
	check.call(scene.screen == "game", "Échap ramène de l'écran Évolution à la carte")
	# Purchase only through the explicit button; tabs and states are written, not colour-only.
	scene.world.points = 40
	scene.open_evolution("transmission")
	await tree.process_frame
	await tree.process_frame
	check.call("Diffusion · 0/" in scene.evolution_tabs.diffusion.text, "Onglet indique les compétences acquises")
	check.call("12 pts · Disponible" in scene.evolution_reasons.transmission.text and "Prérequis" in scene.evolution_reasons.mobility.text, "États écrits sur les nœuds")
	await inputs.click(tree, scene.evolution_buttons.transmission)
	check.call(scene.world.purchased.is_empty(), "Cliquer un nœud ne dépense rien")
	await inputs.click(tree, scene.evolution_purchase)
	check.call("transmission" in scene.world.purchased and scene.world.points == 28, "Évoluer achète au coût exact")
	check.call("Diffusion · 1/" in scene.evolution_tabs.diffusion.text and scene.evolution_reasons.transmission.text == "Acquise" and scene.evolution_purchase.disabled, "Achat reflété sur l'onglet, le nœud et le bouton")
	check.call("acquise" in scene.status_label.text and "28" in scene.status_label.text, "Confirmation d'achat avec points restants")
	scene.evolution_tabs.discretion.pressed.emit()
	await tree.process_frame
	check.call(scene.evolution_family == "discretion" and scene.selected_evolution == "discretion" and scene.evolution_buttons.has("discretion"), "Changer d'onglet sélectionne sa première compétence")
	scene.close_evolution()
	check.call("Diffusion 1/" in scene.evolution_summary.text and "28 pts" in scene.evolution_open_button.text, "Résumé de la carte mis à jour")
	# No Évolution screen outside a running game.
	scene.show_menu()
	scene.open_evolution()
	check.call(scene.screen == "menu", "Pas d'écran Évolution depuis le menu")
	scene.queue_free()
	await tree.process_frame
	tree.root.size = Vector2i(1280, 720)

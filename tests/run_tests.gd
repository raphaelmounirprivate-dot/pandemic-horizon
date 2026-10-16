extends SceneTree

const World = preload("res://scripts/simulation/world.gd")
var failures: int = 0
var checks: int = 0

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + description)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	check(World.validate_data(data).is_empty(), "Données livrées valides")
	for mutation in ["duplicate", "population", "edge", "position", "version", "reverse_edge"]:
		var invalid = data.duplicate(true)
		match mutation:
			"duplicate": invalid.regions[1].id = invalid.regions[0].id
			"population": invalid.regions[0].population = -1
			"edge": invalid.connections.append(["absent", "boreale"])
			"position": invalid.regions[0].position = [2, 0]
			"version": invalid.schema_version = 99
			"reverse_edge": invalid.connections.append(["occident", "boreale"])
		check(not World.validate_data(invalid).is_empty(), "Rejet données : " + mutation)
	check(not World.validate_data(null).is_empty(), "JSON absent refusé")
	var model = World.new()
	check(model.start("inconnue") != "", "Départ inconnu refusé")
	check(model.start("boreale").is_empty(), "Initialisation")
	check(model.totals().population == 3530000, "Population totale des 24 régions")
	check(model.totals().active == 200, "Cas initiaux")
	check(model.purchase("transmission") != "", "Achat sans points refusé")
	check(model.points == 8 and model.purchased.is_empty(), "Refus sans mutation")
	model.points = 50
	check(model.purchase("transmission").is_empty(), "Achat autorisé")
	check(model.points == 38, "Coût exact")
	check(model.purchase("transmission") != "", "Double achat refusé")
	check(model.points == 38, "Double achat sans débit")
	check(model.purchase("absent") != "", "Évolution inconnue refusée")
	# A seeded replay checks the full state and RNG, not only an end score.
	var first = World.new()
	var second = World.new()
	first.start("boreale", 42)
	second.start("boreale", 42)
	for day_index in range(80):
		if day_index == 10:
			first.purchase("mobility")
			second.purchase("mobility")
		first.step()
		second.step()
	check(first.regions == second.regions and first.rng.state == second.rng.state, "Rejeu déterministe complet")
	check(first.cure == second.cure and first.points == second.points, "Rejeu remède et points")
	check(first.active_events == second.active_events and first.activated_events == second.activated_events and first.journal == second.journal, "Rejeu complet des événements et réactions")
	# No active connections means no spontaneous spread to an isolated region.
	var isolated = data.duplicate(true)
	isolated.connections = []
	model.start("boreale", 3, isolated, load("res://tests/test_gameplay.gd").new().clean_content())
	for i in range(30): model.step()
	check(model.regions[1].active == 0, "Pas de diffusion sans connexion")
	# Reversing edge traversal must not change any simulation result.
	var reversed = data.duplicate(true)
	reversed.connections.reverse()
	first.start("boreale", 8, data)
	second.start("boreale", 8, reversed)
	for i in range(50):
		first.step()
		second.step()
	check(first.regions == second.regions, "Échanges indépendants de l'ordre des connexions")
	# Verify each upgrade changes the promised observable behavior.
	for id in first.evolutions:
		if id in World.SPECIALIZATIONS: continue # Dedicated suite checks each mode and its cure trade-off.
		first.start("boreale", 10)
		second.start("boreale", 10)
		second.points = 100
		for prerequisite in second.evolutions[id].requires:
			first.points = 100
			first.purchase(prerequisite)
			second.purchase(prerequisite)
		second.purchase(id)
		for i in range(35):
			first.step()
			second.step()
		if id == "discretion":
			check(second.cure < first.cure, "Discrétion ralentit le remède")
		else:
			check(second.totals().touched > first.totals().touched, "Effet observable : " + id)
	# Invariants across starts/seeds and both with/without purchases.
	var wins = 0
	var losses = 0
	for seed_value in range(12):
		for start in data.regions:
			model.start(start.id, seed_value)
			for i in range(500):
				if seed_value % 2 == 0:
					for id in model.evolutions: model.purchase(id)
				model.step()
				var valid = model.cure >= 0 and model.cure <= 100 and model.points >= 0
				for region in model.regions:
					valid = valid and region.healthy >= 0 and region.active >= 0 and region.removed >= 0
					valid = valid and region.healthy + region.active + region.removed == region.population
				if not valid:
					check(false, "Invariant population/bornes")
					break
				if not model.outcome.is_empty(): break
			check(not model.outcome.is_empty(), "Partie terminée avant 500 jours")
			var end = model.regions.duplicate(true)
			var end_day = model.day
			model.step()
			check(model.regions == end and model.day == end_day, "Fin de partie immuable")
			if model.outcome == "victory": wins += 1
			else: losses += 1
	print("Exploration : %d victoires, %d défaites sur %d parties (pas une mesure d'équilibrage)." % [wins, losses, data.regions.size() * 12])
	check(wins > 0 and losses > 0, "Victoire et défaite possibles sur les parcours explorés")
	# Explicit victory, defeat and same-day priority fixtures.
	model.start("boreale")
	for region in model.regions:
		region.healthy = 0
		region.active = 0
		region.removed = int(region.population)
	model.resolve_outcome()
	check(model.outcome == "victory", "Victoire avant extinction si objectif atteint")
	model.cure = 100.0
	model.resolve_outcome()
	check(model.outcome == "defeat_cure", "Remède prioritaire en fin simultanée")
	model.start("boreale")
	model.regions[0].healthy += model.regions[0].active
	model.regions[0].active = 0
	model.resolve_outcome()
	check(model.outcome == "defeat_extinction", "Défaite par extinction")
	check(model.purchase("mobility") != "", "Achat interdit après résultat")
	model.start("orient")
	check(model.day == 0 and model.points == 8 and model.outcome == "" and model.purchased.is_empty(), "Nouvelle partie réinitialisée")
	var before_gameplay = checks
	load("res://tests/test_gameplay.gd").new().run(check)
	check(checks - before_gameplay >= 59, "Suite gameplay entièrement exécutée")
	var before_scenarios = checks
	load("res://tests/test_scenarios.gd").new().run(check)
	check(checks - before_scenarios >= 180, "Suite scénarios entièrement exécutée")
	# Exercise the actual UI controller without rendering, then its time integration.
	var scene = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.screen == "menu", "Menu au démarrage")
	scene.start_game()
	check(scene.screen == "game" and scene.paused, "Départ en pause")
	var key = InputEventKey.new()
	key.keycode = KEY_SPACE
	key.pressed = true
	scene._input(key)
	check(not scene.paused, "Raccourci Espace reprend")
	scene._input(key)
	check(scene.paused, "Raccourci Espace suspend")
	scene.advance_time(10.0)
	check(scene.world.day == 0, "Pause sans progression")
	scene.toggle_pause()
	scene.advance_time(1.0)
	check(scene.world.day == 2, "Deux journées par seconde à ×1")
	scene.show_menu()
	scene.advance_time(10.0)
	check(scene.world.day == 2 and scene.paused, "Menu suspend la partie")
	scene.show_game()
	check(scene.world.day == 2, "Reprise conserve le monde")
	scene.start_game()
	scene.toggle_pause()
	for i in range(20): scene.advance_time(0.5)
	var normal = scene.world.regions.duplicate(true)
	scene.start_game()
	scene.speed = 4
	scene.toggle_pause()
	for i in range(5): scene.advance_time(0.5)
	check(scene.world.regions == normal and scene.world.day == 20, "Vitesse ×4 conserve les règles")
	scene.show_settings()
	check(scene.screen == "settings", "Paramètres accessibles")
	scene.start_game()
	scene.toggle_pause()
	for i in range(500): scene.advance_time(0.5)
	check(scene.screen == "result", "Bilan atteint depuis le contrôleur réel")
	scene.start_game()
	check(scene.screen == "game" and scene.world.day == 0, "Rejouer après résultat")
	scene.queue_free()
	await process_frame
	var before_input = checks
	await load("res://tests/input_journey.gd").new().run(self, check)
	check(checks - before_input >= 15, "Parcours d'entrée entièrement exécuté")
	var before_map = checks
	await load("res://tests/test_map.gd").new().run(self, check)
	check(checks - before_map >= 33, "Suite carte entièrement exécutée")
	var before_persistence = checks
	await load("res://tests/test_persistence.gd").new().run(self, check)
	check(checks - before_persistence >= 165, "Suite sauvegardes entièrement exécutée")
	var before_onboarding = checks
	await load("res://tests/test_onboarding.gd").new().run(self, check)
	check(checks - before_onboarding >= 50, "Suite tutoriel et aide entièrement exécutée")
	var before_transports = checks
	await load("res://tests/test_transports.gd").new().run(self, check)
	check(checks - before_transports >= 80, "Suite transports entièrement exécutée")
	var before_specializations = checks
	await load("res://tests/test_specializations.gd").new().run(self, check)
	check(checks - before_specializations >= 100, "Suite spécialisations et compatibilité entièrement exécutée")
	var before_comparison = checks
	load("res://tests/test_strategy_comparison.gd").new().run(check)
	check(checks - before_comparison >= 40, "Suite comparaison des stratégies entièrement exécutée")
	var before_objectives = checks
	await load("res://tests/test_objectives.gd").new().run(self, check)
	check(checks - before_objectives >= 75, "Suite objectifs et compatibilité 0.8 entièrement exécutée")
	print("RESULT: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)

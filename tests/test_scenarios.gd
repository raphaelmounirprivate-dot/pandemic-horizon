extends RefCounted

const World = preload("res://scripts/simulation/world.gd")
const Scenarios = preload("res://scripts/gameplay/scenarios.gd")

func run(check: Callable) -> void:
	var data = JSON.parse_string(FileAccess.get_file_as_string(World.DATA_PATH))
	var base = World.Content.load_files()
	var catalog = Scenarios.load_catalog()
	check.call(Scenarios.validate(catalog, data, base).is_empty(), "Catalogue scénarios valide")
	for mutation in ["version", "difficulty", "duplicate", "forced", "cold", "route", "route_duplicate", "date", "phase_order", "phase_zero", "temperature", "factor", "evolution", "events"]:
		var invalid = catalog.duplicate(true)
		var degel = invalid.scenarios[1]
		match mutation:
			"version": invalid.schema_version = 99
			"difficulty": invalid.difficulties[0].cure_multiplier = -1
			"duplicate": degel.id = "standard"
			"forced": degel.forced_start = "absent"
			"cold": degel.cold_regions = ["absent"]
			"route": degel.seasonal_routes[0].edge = ["boreale", "absent"]
			"route_duplicate": degel.seasonal_routes.append(degel.seasonal_routes[0].duplicate(true))
			"date": degel.seasonal_routes[0].open_day = -1
			"phase_order": degel.phases[2].start_day = 5
			"phase_zero": degel.phases[0].start_day = 1
			"temperature": degel.phases[0].temperature = NAN
			"factor": degel.phases[0].cold_factor = 0
			"evolution": degel.extra_evolutions[0].requires = ["absent"]
			"events": degel.events_override[0].target = ["absent", "centrale"]
		check.call(not Scenarios.validate(invalid, data, base).is_empty(), "Rejet scénario : " + mutation)
	var model = World.new()
	check.call(not model.start("boreale", 2042, null, null, "absent").is_empty(), "Scénario inconnu refusé")
	check.call(not model.start("boreale", 2042, null, null, "standard", "absent").is_empty(), "Difficulté inconnue refusée")
	check.call(not model.start("orient", 2042, null, null, "degel2042").is_empty(), "Départ imposé contrôlé par le moteur")
	check.call(model.start("boreale", 2042, null, null, "degel2042").is_empty(), "Dégel démarre")
	check.call(model.phase.id == "isolation" and model.phase.temperature == -18, "Phase et température initiales")
	check.call(model.connections.size() == 9 and not model.route_is_open(["boreale", "orient"]), "Route arctique ajoutée mais fermée initialement")
	check.call(not model.route_is_open(["boreale", "centrale"]) and model.route_is_open(["boreale", "occident"]), "Isolement conserve une seule sortie de Boréale")
	check.call(model.evolutions.has("polar") and model.evolutions.size() == 6, "Trois évolutions spécifiques au scénario")
	model.day = 11
	model.step()
	check.call(model.phase.id == "opening" and model.route_is_open(["boreale", "orient"]), "Ouverture au jour 12")
	check.call(model.journal.any(func(line): return "Saison ouverte" in line), "Ouverture annoncée")
	model.day = 27
	model.step()
	check.call(model.phase.id == "instability" and not model.route_is_open(["boreale", "centrale"]), "Tempête et instabilité au jour 28")
	model.day = 30
	model.step()
	model.day = 35
	model.step()
	check.call(not model.route_is_open(["boreale", "centrale"]), "Fin de tempête ne supprime pas l'inspection")
	model.day = 38
	model.step()
	check.call(model.route_is_open(["boreale", "centrale"]), "Route saisonnière rétablie au jour 39")
	model.day = 54
	model.step()
	check.call(model.phase.id == "mobilization" and model.phase.cure_multiplier == 1.35, "Mobilisation au jour 55")
	model.points = 100
	var initial_factor = model.climate_factor("boreale")
	model.purchase("polar")
	check.call(is_equal_approx(model.climate_factor("boreale"), initial_factor * 1.25), "Adaptation polaire mesurable")
	check.call(is_equal_approx(model.climate_factor("orient"), 0.95), "Adaptation polaire limitée au froid")
	model.purchase("resilience")
	check.call(is_equal_approx(model.climate_factor("boreale"), 0.95 * 1.25), "Résilience réduit la pénalité climatique de moitié")
	check.call(is_equal_approx(model.climate_factor("orient"), 0.975), "Résilience s'applique aux pénalités chaudes aussi")
	# Seasonal mobility changes exchanges on a seasonal route, not on ordinary ones.
	var first = World.new()
	var second = World.new()
	for world in [first, second]:
		world.start("boreale", 4, null, null, "degel2042")
		world.day = 11
		world.points = 100
		world.purchase("polar")
		world.regions[0].active = 10000
		world.regions[0].healthy = 90000
	second.purchase("seasonal")
	first.step()
	second.step()
	check.call(second.regions[4].active == first.regions[4].active * 2, "Mobilité saisonnière double les cas importés sur route arctique")
	check.call(second.regions[1].active == first.regions[1].active, "Mobilité saisonnière sans effet sur route ordinaire")
	# Opening season does not cancel a temporary closure already in force.
	var blocked_catalog = catalog.duplicate(true)
	blocked_catalog.scenarios[1].events_override = [{"id":"early_storm","name":"Tempête précoce","kind":"route_closure","start_day":1,"duration":20,"target":["boreale","orient"],"factor":1.0}]
	model.start("boreale", 4, data, base, "degel2042", "normal", blocked_catalog)
	model.step()
	model.day = 11
	model.step()
	check.call(not model.route_is_open(["boreale", "orient"]), "Ouverture saisonnière respecte une fermeture active")
	# Difficulty is a transparent world-response coefficient, not a growth cheat.
	first.start("boreale", 12, null, null, "standard", "easy")
	second.start("boreale", 12, null, null, "standard", "hard")
	for world in [first, second]:
		world.regions[0].active = 1300
		world.regions[0].healthy = 98700
		world.step()
	check.call(not first.regions[0].detected and second.regions[0].detected, "Seuils de détection distincts selon difficulté")
	for world in [first, second]:
		world.start("boreale", 12, null, null, "standard", "easy" if world == first else "hard")
		world.regions[0].detected = true
		world.step()
	check.call(first.regions == second.regions and second.cure > first.cure, "Recherche plus rapide en difficile, même croissance avant réaction")
	check.call(second.score() >= first.score(), "Score pondéré par difficulté")
	model.start("boreale", 2042, null, null, "degel2042")
	var prior = model.scenario.duplicate(true)
	check.call(not model.start("orient", 2042, null, null, "degel2042").is_empty() and model.scenario == prior, "Refus de départ conserve le scénario existant")
	model.start("orient")
	check.call(model.scenario.id == "standard" and model.connections.size() == 8 and not model.evolutions.has("polar"), "Retour standard sans état climatique résiduel")
	# Real complete runs cover all scenario/difficulty combinations and seeded replay.
	var outcomes: Dictionary = {}
	for scenario_id in ["standard", "degel2042"]:
		var wins = 0
		var losses = 0
		for difficulty_id in ["easy", "normal", "hard"]:
			for seed_value in range(8):
				first.start("boreale", seed_value, null, null, scenario_id, difficulty_id)
				second.start("boreale", seed_value, null, null, scenario_id, difficulty_id)
				for i in range(500):
					for world in [first, second]:
						if seed_value % 2 == 0:
							for id in world.evolutions: world.purchase(id)
						world.step()
					if not first.outcome.is_empty(): break
				check.call(not first.outcome.is_empty(), "Partie terminable : " + scenario_id + "/" + difficulty_id)
				check.call(first.regions == second.regions and first.phase == second.phase and first.active_events == second.active_events and first.cure == second.cure and first.journal == second.journal, "Rejeu climat/difficulté : " + scenario_id + "/" + difficulty_id)
				var valid = first.cure <= 100 and first.points >= 0
				for region in first.regions:
					valid = valid and region.active >= 0 and region.healthy >= 0 and region.removed >= 0 and region.active + region.healthy + region.removed == region.population
				check.call(valid, "Invariants après partie : " + scenario_id)
				if first.outcome == "victory": wins += 1
				else: losses += 1
		outcomes[scenario_id] = [wins, losses]
		print("Scénario %s : %d victoires, %d défaites sur 24 parties." % [scenario_id, wins, losses])
		check.call(wins > 0 and losses > 0, "Victoire et défaite observées : " + scenario_id)
	# A legal deliberate strategy can win Dégel at every difficulty, without free points.
	for difficulty_id in ["easy", "normal", "hard"]:
		model.start("boreale", 2042, null, null, "degel2042", difficulty_id)
		for i in range(500):
			for id in ["discretion", "transmission", "mobility"]:
				if id not in model.purchased:
					model.purchase(id)
					break
			model.step()
			if not model.outcome.is_empty(): break
		check.call(model.outcome == "victory" and model.phase.id == "mobilization", "Dégel gagnable avec achats légaux : " + difficulty_id)

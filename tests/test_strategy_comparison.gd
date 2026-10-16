extends RefCounted
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const World = preload("res://scripts/simulation/world.gd")

func run(check: Callable) -> void:
	var orders = [[], ["transmission", "mobility", "land_network", "discretion"], ["transmission", "mobility", "discretion", "air_bridge"]]
	for scenario in ["standard", "degel2042"]:
		for order in orders:
			var observed = Comparison.play("boreale", 42, scenario, "hard", order)
			check.call(observed.error.is_empty(), "Analyse : partie terminée " + scenario + str(order))
			if not observed.error.is_empty(): continue
			# Independent legacy loop and full purchase-state audit, including timing.
			var world = World.new()
			world.start("boreale", 42, null, null, scenario, "hard")
			var trace: Array = []
			for day in range(500):
				for id in order:
					if id not in world.purchased:
						var before = world.points
						if world.purchase(id).is_empty(): trace.append({"id":id, "day":world.day, "before":before, "after":world.points})
						break
				world.step()
				if not world.outcome.is_empty(): break
			check.call(observed.outcome == world.outcome and observed.days == world.day and observed.coverage == world.coverage() and observed.score == world.score(), "Analyse conserve les résultats de l'ancienne boucle")
			check.call(observed.purchases == trace and observed.ticks == world.day, "Trace exacte : achats légaux, jours et points")
			var replay = Comparison.play("boreale", 42, scenario, "hard", order)
			for key in ["total_usec", "max_usec"]:
				observed.erase(key)
				replay.erase(key)
			check.call(observed == replay, "Résultats et trace reproductibles hors chronométrage")
	for bad in [["absent"], ["mobility"], ["transmission", "transmission"], ["transmission", "mobility", "air_bridge", "sea_logistics"]]:
		check.call(not Comparison.play("boreale", 7, "standard", "normal", bad).error.is_empty(), "Politique impossible refusée " + str(bad))
	check.call(not Comparison.play("absent", 7, "standard", "normal", []).error.is_empty(), "Erreur de départ propagée")
	check.call(not Comparison.play("boreale", 7, "standard", "normal", [], 1).error.is_empty(), "Partie tronquée refusée au lieu d'une fausse défaite")
	var rows: Array = []
	for seed_value in range(4):
		for late in [false, true]:
			var won = (seed_value == 0 or seed_value == (2 if late else 1))
			rows.append({"scenario":"standard", "difficulty":"hard", "start":"boreale", "seed":seed_value,
				"policy":"terrestre_discretion_avant" if late else "terrestre", "outcome":"victory" if won else "defeat_cure",
				"days":80 if late else 90, "purchases":[{"id":"land_network"}] if seed_value != 3 else []})
	rows.reverse()
	var paired = Comparison.pair_rows(rows)
	check.call(paired.error.is_empty() and paired.pairs.size() == 4, "Appariement par identité malgré l'ordre inversé")
	var stats = Comparison.summarize(paired.pairs)
	check.call(stats.early_only == 1 and stats.late_only == 1 and stats.both == 1 and stats.neither == 1, "Quatre résultats appariés comptés sans confusion")
	check.call(stats.win_day_delta == -10 and stats.early_bought == 3 and stats.late_bought == 3, "Durée des doubles victoires et achats réellement effectués")
	var markdown = Comparison.report(paired.pairs)
	check.call(markdown.contains("| 4 | 1 | 1 | 1 | 1 | 3/3 | -10.00 |"), "Rapport : dénominateurs et signe du delta exacts")
	check.call(markdown.contains("## Par départ") and markdown.contains("hard / terrestre / boreale"), "Rapport ventilé par départ")
	check.call(Comparison.table_row("aucune double victoire", Comparison.summarize([])).ends_with("| — |\n"), "Pas de moyenne fictive sans double victoire")
	var duplicate = rows.duplicate(true)
	duplicate.append(rows[0])
	check.call(not Comparison.pair_rows(duplicate).error.is_empty(), "Doublon refusé")
	var missing = rows.duplicate(true)
	missing.pop_back()
	check.call(not Comparison.pair_rows(missing).error.is_empty(), "Paire incomplète refusée")
	var mismatch = rows.duplicate(true)
	mismatch[0].start = "centrale"
	check.call(not Comparison.pair_rows(mismatch).error.is_empty(), "Départs différents jamais appariés")
	var no_specialization = [{"policy":"attente"}]
	check.call(Comparison.pair_rows(no_specialization).pairs.is_empty(), "Politiques témoins exclues de la comparaison appariée")

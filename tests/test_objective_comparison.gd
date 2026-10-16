extends RefCounted
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const Analysis = preload("res://scripts/analysis/objective_comparison.gd")

func run(check: Callable) -> void:
	check.call(Comparison.policies(false).size() == 10 and Comparison.policies().size() == 11, "Politiques Standard et Dégel conservées")
	var policies = Comparison.policies(false)
	policies.mobilite.append("absent")
	check.call("absent" not in Comparison.policies(false).mobilite, "Les ordres retournés ne modifient pas le catalogue")
	for start in ["boreale", "pacifique"]:
		for difficulty in ["easy", "hard"]:
			for policy in ["attente", "mobilite"]:
				var active = Comparison.play(start,42,"standard",difficulty,Comparison.policies(false)[policy],500,Analysis.ID)
				var control = Comparison.play(start,42,"standard",difficulty,Comparison.policies(false)[policy])
				check.call(active.error.is_empty() and control.error.is_empty(), "Analyse objectif : deux parties légales terminées")
				if not active.error.is_empty() or not control.error.is_empty(): continue
				active.policy = policy
				control.policy = policy
				var paired = Analysis.pair_rows([active,control])
				check.call(paired.error.is_empty() and paired.pairs.size() == 1, "Objectif et témoin : état/RNG/achats identiques")
				check.call(control.objective.is_empty() and active.objective.status in ["completed","failed"], "Témoin absent distinct d'un objectif résolu")
	check.call(not Comparison.play("boreale",42,"degel2042","normal",[],500,Analysis.ID).error.is_empty(), "Analyse objectif Dégel refusée")
	check.call(not Comparison.play("boreale",42,"standard","normal",[],500,"absent").error.is_empty(), "Objectif d'analyse inconnu refusé")
	var rows: Array = []
	for seed_value in range(4):
		var won = seed_value in [0,2]
		var success = seed_value in [0,1]
		for enabled in [true,false]:
			rows.append({"scenario":"standard","difficulty":"hard","start":"boreale","seed":seed_value,"policy":"mobilite",
				"objective_id":Analysis.ID if enabled else "", "state_hash":"a".repeat(64),
				"objective":{"id":Analysis.ID,"status":"completed" if success else "failed","progress":3 if success else 1,"resolved_day":40 + seed_value if success else 50,"reason":"" if success else "deadline"} if enabled else {},
				"outcome":"victory" if won else "defeat_cure","days":100,"coverage":0.95 if won else 0.8,"score":100,"purchases":[]})
	rows.reverse()
	var paired = Analysis.pair_rows(rows)
	check.call(paired.error.is_empty() and paired.pairs.size() == 4, "Appariement objectif par identité, pas par ordre")
	var stats = Analysis.summarize(paired.pairs)
	check.call(stats.count == 4 and stats.both == 1 and stats.objective_only == 1 and stats.main_only == 1 and stats.neither == 1, "Matrice des quatre combinaisons sans confondre les fins")
	check.call(stats.successes == 2 and stats.sum_day == 81 and stats.min_day == 40 and stats.max_day == 41, "Dates limitées aux réussites : échecs exclus")
	var text = Analysis.report(paired.pairs)
	check.call(text.contains("| 4 | 2 | 50.0 % | 1 | 1 | 1 | 1 | 40.50 | 40–41 |"), "Rapport : dénominateur actif et moyenne de réussite exacts")
	check.call(text.contains("hard / boreale / mobilite") and text.contains("## Ordres d'achat"), "Rapport par départ et politiques reproductibles")
	check.call(Analysis.table_row("vide",Analysis.summarize([])).contains("| 0 | 0 | — |"), "Pas de taux fictif sans observations")
	var no_success = Analysis.summarize([paired.pairs[2],paired.pairs[3]])
	check.call(no_success.successes == 0 and Analysis.table_row("échecs",no_success).ends_with("| — | — |\n"), "Aucune date de réussite inventée pour les échecs")
	for mutation in ["missing", "duplicate", "start", "seed", "policy", "hash", "outcome", "days", "coverage", "score", "purchases", "mode", "pending", "future", "threshold", "late", "control", "missing_field"]:
		var bad = rows.duplicate(true)
		# Row0 is the control, row1 its active match for seed3 (failed).
		match mutation:
			"missing": bad.pop_back()
			"duplicate": bad.append(bad[0])
			"start": bad[0].start = "pacifique"
			"seed": bad[0].seed = 99
			"policy": bad[0].policy = "attente"
			"hash": bad[0].state_hash = "b".repeat(64)
			"outcome": bad[0].outcome = "victory"
			"days": bad[0].days = 101
			"coverage": bad[0].coverage = 0.7
			"score": bad[0].score = 101
			"purchases": bad[0].purchases = [{"id":"transmission","day":10}]
			"mode": bad[1].objective_id = "absent"
			"pending": bad[1].objective.status = "pending"
			"future": bad[1].objective.resolved_day = 101
			"threshold": bad[1].objective.status = "completed"; bad[1].objective.reason = ""
			"late": bad[1].objective.status = "completed"; bad[1].objective.reason = ""; bad[1].objective.progress = 3; bad[1].objective.resolved_day = 51
			"control": bad[0].objective = bad[1].objective.duplicate(true)
			"missing_field": bad[0].erase("state_hash")
		check.call(not Analysis.pair_rows(bad).error.is_empty(), "Comparaison invalide refusée : " + mutation)

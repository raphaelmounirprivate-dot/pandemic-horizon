extends RefCounted
const Arctic = preload("res://scripts/analysis/arctic_analysis.gd")
const Analysis = preload("res://scripts/analysis/objective_comparison.gd")
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")

func run(check: Callable) -> void:
	check.call(Arctic.policies().size() == 15 and Comparison.policies().size() == 11,"Ordres précoces ajoutés sans modifier les politiques historiques")
	var orders = Arctic.policies()
	orders.saisonnier.append("absent")
	check.call("absent" not in Arctic.policies().saisonnier,"Catalogue arctique retourné par copie")
	var rows: Array = []
	for policy in ["polaire","saisonnier","polaire_diffusion","resilience_precoce","saisonnier_discret"]:
		for objective_id in [Arctic.ID,""]:
			var row = Comparison.play("boreale",42,"degel2042","normal",Arctic.policies()[policy],500,objective_id)
			check.call(row.error.is_empty(),"Ordre climatique légal terminé : " + policy)
			if not row.error.is_empty(): continue
			row.policy = policy
			rows.append(row)
	rows.reverse()
	var paired = Analysis.pair_rows(rows,Arctic.ID,Arctic.policies())
	check.call(paired.error.is_empty() and paired.pairs.size() == 5,"Paires arctiques exactes avec ordres précoces")
	var by_policy: Dictionary = {}
	for pair in paired.pairs: by_policy[pair.active.policy] = pair
	check.call(by_policy.polaire.active.objective.status == "failed" and by_policy.saisonnier.active.objective.status == "completed","L'ordre saisonnier précoce a un effet observable sur l'objectif")
	var late = Arctic.purchases([by_policy.polaire],"seasonal",54)
	var early = Arctic.purchases([by_policy.saisonnier],"seasonal",54)
	check.call(late.acquired == 1 and late.in_time == 0 and late.min_day > 54,"Achat historique tardif distingué d'un achat absent")
	check.call(early.acquired == 1 and early.in_time == 1 and early.min_day == 20,"Mobilité saisonnière précoce achetée au jour légal 20")
	var synthetic = [
		{"active":{"purchases":[{"id":"seasonal","day":54}]}},
		{"active":{"purchases":[{"id":"seasonal","day":55}]}},
		{"active":{"purchases":[]}}]
	var stats = Arctic.purchases(synthetic,"seasonal",54)
	check.call(stats.count == 3 and stats.acquired == 2 and stats.in_time == 1 and stats.min_day == 54 and stats.max_day == 55,"Échéance incluse et dates des seuls achats réels")
	check.call(Arctic.purchase_row("test",stats) == "| test | 3 | 2 | 1 | 54–55 |\n","Table des achats : dénominateurs explicites")
	check.call(Arctic.purchase_row("absent",Arctic.purchases(synthetic,"resilience",54)).ends_with("| — |\n"),"Aucune date inventée sans acquisition")
	var report = Arctic.report(paired.pairs)
	check.call(report.contains("Empreinte du contenu") and report.contains("## Politiques") and report.contains("normal / saisonnier / seasonal"),"Rapport reproductible et détail des achats")
	check.call(not Analysis.pair_rows(rows).error.is_empty(),"Les règles Standard ne sont pas appliquées aux paires Dégel")
	var active = by_policy.saisonnier.active
	var control = by_policy.saisonnier.control
	for mutation in ["missing","overflow","negative","extra","progress","early","pending","scenario","hash","duplicate","missing_control","policy"]:
		var bad = [active.duplicate(true),control.duplicate(true)]
		match mutation:
			"missing": bad[0].objective.routes.erase("orient")
			"overflow": bad[0].objective.routes.orient = 1001
			"negative": bad[0].objective.routes.orient = -1
			"extra": bad[0].objective.routes.other = 0
			"progress": bad[0].objective.progress = 0
			"early": bad[0].objective.resolved_day = 36
			"pending": bad[0].objective.status = "pending"
			"scenario": bad[0].scenario = "standard"
			"hash": bad[0].state_hash = "f".repeat(64)
			"duplicate": bad.append(bad[0])
			"missing_control": bad.pop_back()
			"policy": bad[0].policy = "absent"
		check.call(not Analysis.pair_rows(bad,Arctic.ID,Arctic.policies()).error.is_empty(),"Analyse arctique incohérente refusée : " + mutation)

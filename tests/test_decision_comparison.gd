extends RefCounted
const Analysis = preload("res://scripts/analysis/decision_comparison.gd")

func run(check: Callable) -> void:
	var rows: Array = []
	for funding in Analysis.FUNDING:
		for policy in ["mobilite","saisonnier","attente"]:
			for arm in Analysis.ARMS:
				var row = Analysis.play("normal",42,policy,arm,funding)
				check.call(row.error.is_empty(),"Analyse légale terminée : " + funding + "/" + policy + "/" + arm)
				if row.error.is_empty(): rows.append(row)
	var paired = Analysis.pair_rows(rows)
	check.call(paired.error.is_empty() and paired.get("groups",[]).size() == 6,"Six groupes de quatre variantes, budget et témoins vérifiés")
	if not paired.error.is_empty(): return
	var ordinary = Analysis.select(rows,"ordinary","support").filter(func(row): return row.policy == "mobilite")[0]
	var reserve = Analysis.select(rows,"reserve","support").filter(func(row): return row.policy == "mobilite")[0]
	check.call(ordinary.decision.choice == "observe" and ordinary.decision.reason == "timeout","Soutien demandé sans points distingué du soutien réellement appliqué")
	check.call(ordinary.decision_attempts.size() == 3 and ordinary.decision_attempts[0].day == 28 and ordinary.decision_attempts[2].day == 30,"Trois tentatives avant la neutralisation J31")
	check.call(reserve.decision.choice == "support" and reserve.decision.day == 28,"Réserve légale rend le soutien disponible au J28")
	check.call(reserve.purchases != ordinary.purchases,"Coût et réserve modifient les achats réellement observés")
	check.call(Analysis.contrasts(paired.groups,"ordinary","observe").win_gain == 0 and Analysis.contrasts(paired.groups,"ordinary","observe").purchase_delays == 0,"Maintien sans effet sur résultats et dates d'achat")
	var neutral = Analysis.select(rows,"reserve","observe")
	check.call(Analysis.stats(neutral).selected == neutral.size(),"Dénominateur de choix réellement appliqués")
	var report = Analysis.report(rows,paired.groups)
	check.call(report.contains("## Progression du remède") and report.contains("## Dates des achats"),"Rapport inclut remède daté et chronologie")
	check.call(Analysis.table_row("absent",[]).is_empty() and not Analysis.pair_rows([]).error.is_empty(),"Pas de ligne chiffrée inventée pour une cohorte absente")
	for args in [["normal",42,"unknown","support","ordinary",500],["normal",42,"mobilite","unknown","ordinary",500],["normal",42,"mobilite","support","unknown",500],["impossible",42,"mobilite","support","ordinary",500],["normal",42,"mobilite","support","ordinary",1]]:
		check.call(not Analysis.play.callv(args).error.is_empty(),"Paramètres invalides ou partie non terminée refusés")
	var group = paired.groups[0]
	var valid: Array = []
	for arm in Analysis.ARMS: valid.append(group[arm])
	for mutation in ["missing","duplicate","field","scenario","start","seed","policy","funding","arm","before","hash","points","purchase","attempt","choice","sample","sample_day","goal","cure"]:
		var bad = valid.duplicate(true)
		match mutation:
			"missing": bad.pop_back()
			"duplicate": bad.append(bad[0].duplicate(true))
			"field": bad[0].erase("decision_attempts")
			"scenario": bad[0].scenario = "standard"
			"start": bad[0].start = "orient"
			"seed": bad[0].seed = "42"
			"policy": bad[0].policy = "unknown"
			"funding": bad[0].funding = "unknown"
			"arm": bad[0].arm = "unknown"
			"before": bad[2].pre_hash = "f".repeat(64)
			"hash": bad[1].state_hash = "f".repeat(64)
			"points": bad[2].points += 1
			"purchase": bad[1].purchases.append({"id":"transmission","day":0,"before":8,"after":-4})
			"attempt": bad[2].decision_attempts.clear()
			"choice": bad[2].decision.choice = "limit"
			"sample": bad[0].samples.pop_back()
			"sample_day": bad[0].samples[1].day = 27
			"goal": bad[2].objective.routes.orient = 1001
			"cure": bad[2].cure = NAN
		check.call(not Analysis.pair_rows(bad).error.is_empty(),"Cohorte incohérente refusée : " + mutation)

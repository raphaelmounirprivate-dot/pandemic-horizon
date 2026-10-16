extends RefCounted
const Comparison = preload("res://scripts/analysis/strategy_comparison.gd")
const Objectives = preload("res://scripts/gameplay/objectives.gd")
const ID = "first_relays"

static func pair_rows(rows: Array) -> Dictionary:
	var groups: Dictionary = {}
	var item = Objectives.definition(ID)
	if item.is_empty(): return {"error":"Objectif d'analyse indisponible."}
	for row in rows:
		if not row is Dictionary: return {"error":"Observation invalide."}
		for key in ["scenario", "difficulty", "start", "seed", "policy", "objective_id", "objective", "state_hash", "outcome", "days", "coverage", "score", "purchases"]:
			if not row.has(key): return {"error":"Observation incomplète : " + key}
		if row.scenario != "standard" or row.difficulty not in ["easy", "normal", "hard"] or not row.start is String or row.start.is_empty() or not row.seed is int or not Comparison.policies(false).has(row.policy): return {"error":"Identité d'observation invalide."}
		if row.objective_id not in ["", ID] or not row.objective is Dictionary: return {"error":"Mode objectif invalide."}
		if not row.state_hash is String or row.state_hash.length() != 64 or row.outcome not in ["victory", "defeat_cure", "defeat_extinction"] or not Objectives.integer(row.days, 1, 500) or not row.purchases is Array: return {"error":"Résultat d'observation invalide."}
		if row.objective_id == "":
			if not row.objective.is_empty(): return {"error":"Témoin avec objectif."}
		else:
			var state = row.objective
			if state.get("id") != ID or state.get("status") not in ["completed", "failed"] or not Objectives.integer(state.get("progress"), 0, int(item.regions)) or not Objectives.integer(state.get("resolved_day"), 1, int(row.days)): return {"error":"Objectif non résolu ou invalide."}
			if state.status == "completed":
				if state.progress != item.regions or state.resolved_day > item.deadline or state.get("reason") != "": return {"error":"Réussite incohérente."}
			elif state.progress >= item.regions or not ((state.get("reason") == "deadline" and state.resolved_day == item.deadline) or (state.get("reason") == "game_over" and state.resolved_day == row.days and row.days < item.deadline)):
				return {"error":"Échec incohérent."}
		var key = JSON.stringify([row.scenario, row.difficulty, row.start, row.seed, row.policy])
		var side = "control" if row.objective_id == "" else "active"
		if not groups.has(key): groups[key] = {}
		if groups[key].has(side): return {"error":"Observation dupliquée : " + key}
		groups[key][side] = row
	var pairs: Array = []
	var keys = groups.keys()
	keys.sort()
	for key in keys:
		var pair = groups[key]
		if not pair.has("control") or not pair.has("active"): return {"error":"Paire incomplète : " + key}
		for field in ["state_hash", "outcome", "days", "coverage", "score", "purchases"]:
			if pair.control[field] != pair.active[field]: return {"error":"Dérive avec objectif : " + field + " / " + key}
		pairs.append(pair)
	return {"error":"", "pairs":pairs}

static func summarize(pairs: Array) -> Dictionary:
	var result = {"count":pairs.size(), "both":0, "objective_only":0, "main_only":0, "neither":0,
		"successes":0, "sum_day":0, "min_day":500, "max_day":0}
	for pair in pairs:
		var success = pair.active.objective.status == "completed"
		var win = pair.active.outcome == "victory"
		if success and win: result.both += 1
		elif success: result.objective_only += 1
		elif win: result.main_only += 1
		else: result.neither += 1
		if success:
			var day = int(pair.active.objective.resolved_day)
			result.successes += 1
			result.sum_day += day
			result.min_day = mini(result.min_day, day)
			result.max_day = maxi(result.max_day, day)
	return result

static func header(label: String) -> String:
	return "| %s | Paires | Objectif réussi | Taux observé | Deux succès | Objectif seul | Victoire seule | Deux échecs | Jour moyen réussi | Jours réussis min–max |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n" % label

static func table_row(label: String, stats: Dictionary) -> String:
	var rate = "—" if stats.count == 0 else "%.1f %%" % (100.0 * stats.successes / stats.count)
	var mean_day = "—" if stats.successes == 0 else "%.2f" % (float(stats.sum_day) / stats.successes)
	var days = "—" if stats.successes == 0 else "%d–%d" % [stats.min_day,stats.max_day]
	return "| %s | %d | %d | %s | %d | %d | %d | %d | %s | %s |\n" % [label, stats.count, stats.successes, rate, stats.both, stats.objective_only, stats.main_only, stats.neither, mean_day, days]

static func report(pairs: Array) -> String:
	var item = Objectives.definition(ID)
	var text = "# Premiers relais — analyse du prototype %s\n\n" % ProjectSettings.get_setting("application/config/version")
	text += "Moteur : `%s`. Empreinte du contenu : `%s`.\n\n" % [Engine.get_version_info().string, Comparison.Store.new().content_hash()]
	text += "Généré par `dev.ps1 BalanceObjectives`. " + Objectives.description(item) + "\n\n"
	text += "Standard uniquement : 24 départs, trois difficultés, graines 7/42/2042, dix politiques. Chaque paire rejoue exactement le même départ, la même graine et le même ordre d'achat, avec puis sans l'objectif. Une tentative du premier achat manquant avant chaque pas ; aucun point offert ; arrêt au résultat, limite de 500 jours.\n\n"
	text += "Le témoin n'a aucun objectif ; il n'est pas compté comme un échec facultatif. Les empreintes des états enregistrables sont comparées en excluant uniquement date d'enregistrement, objectif et journal (ses annonces diffèrent). Populations, remède exact, points, achats, événements, phase, résultat et RNG restent comparés. Résultat, durée, couverture, score et trace d'achats sont aussi comparés explicitement. Toute dérive, paire absente ou dupliquée fait échouer la commande.\n\n"
	text += "Deux succès = objectif réussi et victoire principale ; objectif seul = objectif réussi mais défaite principale ; victoire seule = objectif manqué mais victoire principale. Le taux porte sur les parties avec objectif uniquement. Les dates décrivent les seules réussites ; les échecs n'entrent pas dans leur moyenne. Les taux reflètent ces politiques et graines, sans estimation de difficulté humaine ni garantie pour d'autres stratégies. Les règles ne sont pas ajustées.\n\n"
	text += "## Ensemble\n\n" + header("Échantillon") + table_row("Standard", summarize(pairs))
	var groups: Dictionary = {}
	var starts: Dictionary = {}
	for pair in pairs:
		var row = pair.active
		var key = row.difficulty + " / " + row.policy
		if not groups.has(key): groups[key] = []
		groups[key].append(pair)
		var start_key = row.difficulty + " / " + row.start + " / " + row.policy
		if not starts.has(start_key): starts[start_key] = []
		starts[start_key].append(pair)
	text += "\n## Par difficulté et politique\n\n" + header("Difficulté / politique")
	text += group_rows(groups)
	text += "\n## Par départ\n\n" + header("Difficulté / départ / politique") + group_rows(starts)
	text += "\n## Ordres d'achat\n\n"
	var policies = Comparison.policies(false)
	for policy in policies:
		var names: Array[String] = []
		for id in policies[policy]: names.append(id)
		text += "- `%s` : %s.\n" % [policy, "aucun achat" if names.is_empty() else " → ".join(names)]
	return text

static func group_rows(groups: Dictionary) -> String:
	var text = ""
	var keys = groups.keys()
	keys.sort()
	for key in keys: text += table_row(key, summarize(groups[key]))
	return text

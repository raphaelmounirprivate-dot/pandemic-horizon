extends RefCounted
## Paired observations, never a causal estimate or a human difficulty rating.
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const CHOICES = {"terrestre":"land_network", "aerien":"air_bridge", "maritime":"sea_logistics"}
const POLICIES = {
	"attente": [],
	"discretion": ["discretion", "transmission", "mobility"],
	"diffusion": ["transmission", "discretion", "mobility"],
	"mobilite": ["transmission", "mobility", "discretion"],
	"polaire": ["polar", "transmission", "discretion", "seasonal", "mobility", "resilience"],
	"terrestre": ["transmission", "mobility", "land_network", "discretion"],
	"aerien": ["transmission", "mobility", "air_bridge", "discretion"],
	"maritime": ["transmission", "mobility", "sea_logistics", "discretion"]
}

static func policies(include_polar: bool = true) -> Dictionary:
	var result = POLICIES.duplicate(true)
	if not include_polar: result.erase("polaire")
	for choice in CHOICES:
		result[choice + "_discretion_avant"] = ["transmission", "mobility", "discretion", CHOICES[choice]]
	return result

static func play(start: String, seed_value: int, scenario: String, difficulty: String, order: Array, limit: int = 500, objective_id: String = "") -> Dictionary:
	var world = World.new()
	var error = world.start(start, seed_value, null, null, scenario, difficulty, null, null, objective_id)
	if not error.is_empty(): return {"error":error}
	# Reject impossible policies instead of silently waiting forever on bad IDs/order.
	var seen: Array = []
	for id in order:
		if not world.evolutions.has(id) or id in seen: return {"error":"Évolution inconnue ou répétée : " + str(id)}
		for required in world.evolutions[id].requires:
			if required not in seen: return {"error":"Prérequis absent de la politique : " + str(required)}
		for excluded in world.evolutions[id].get("excludes", []):
			if excluded in seen: return {"error":"Politique incompatible : " + str(id)}
		seen.append(id)
	var purchases: Array = []
	var ticks = 0
	var total_usec = 0
	var max_usec = 0
	for i in range(limit):
		for id in order:
			if id not in world.purchased:
				var before_points = world.points
				if world.purchase(id).is_empty():
					purchases.append({"id":id, "day":world.day, "before":before_points, "after":world.points})
				break
		var before = Time.get_ticks_usec()
		world.step()
		var elapsed = Time.get_ticks_usec() - before
		total_usec += elapsed
		max_usec = maxi(max_usec, elapsed)
		ticks += 1
		if not world.outcome.is_empty(): break
	if world.outcome.is_empty(): return {"error":"Partie sans résultat après %d jours." % limit}
	var state = Store.new().encode(world)
	# Objective announcements intentionally differ; all simulation/save fields remain.
	for key in ["saved_at", "objective", "journal"]: state.erase(key)
	return {"error":"", "scenario":scenario, "difficulty":difficulty, "start":start, "seed":seed_value,
		"outcome":world.outcome, "days":world.day, "coverage":world.coverage(), "score":world.score(),
		"objective_id":objective_id, "objective":world.objective.duplicate(true), "state_hash":JSON.stringify(state, "", true, true).sha256_text(),
		"purchases":purchases, "ticks":ticks, "total_usec":total_usec, "max_usec":max_usec}

static func pair_rows(rows: Array) -> Dictionary:
	var groups: Dictionary = {}
	for row in rows:
		var choice = str(row.policy).trim_suffix("_discretion_avant")
		if not CHOICES.has(choice): continue
		var side = "late" if row.policy.ends_with("_discretion_avant") else "early"
		var key = "%s/%s/%s/%s/%s" % [row.scenario, row.difficulty, row.start, row.seed, choice]
		if not groups.has(key): groups[key] = {"choice":choice}
		if groups[key].has(side): return {"error":"Observation dupliquée : " + key}
		groups[key][side] = row
	var pairs: Array = []
	var keys = groups.keys()
	keys.sort()
	for key in keys:
		if not groups[key].has("early") or not groups[key].has("late"): return {"error":"Paire incomplète : " + key}
		pairs.append(groups[key])
	return {"error":"", "pairs":pairs}

static func summarize(pairs: Array) -> Dictionary:
	var stats = {"count":pairs.size(), "early_only":0, "late_only":0, "both":0, "neither":0,
		"early_bought":0, "late_bought":0, "win_day_delta":0}
	for pair in pairs:
		var a = pair.early.outcome == "victory"
		var b = pair.late.outcome == "victory"
		if a and b:
			stats.both += 1
			stats.win_day_delta += pair.late.days - pair.early.days
		elif a: stats.early_only += 1
		elif b: stats.late_only += 1
		else: stats.neither += 1
		for purchase in pair.early.purchases:
			if purchase.id == CHOICES[pair.choice]: stats.early_bought += 1
		for purchase in pair.late.purchases:
			if purchase.id == CHOICES[pair.choice]: stats.late_bought += 1
	return stats

static func report(pairs: Array) -> String:
	var text = "# Ordre d'achat des spécialisations — règles 0.8\n\n"
	text += "Généré par `dev.ps1 Balance`. A = spécialisation avant Discrétion ; B = Discrétion avant spécialisation. Diffusion puis Mobilité précèdent les deux achats. Une tentative du premier achat manquant par jour, avant le pas ; aucun point offert.\n\n"
	text += "Chaque paire conserve scénario, difficulté, départ et graine (7, 42, 2042). Les parties s'arrêtent au résultat, au plus à 500 jours. Une spécialisation prévue peut ne jamais être achetée : les colonnes acquis comptent les achats réels. Le CSV conserve leurs jours et points avant/après.\n\n"
	text += "Les résultats comparent des politiques complètes : budget, dates et effets changent ensemble. Ils ne mesurent pas un effet causal isolé et ne représentent pas des joueurs humains. Δ jours = B − A, uniquement lorsque les deux gagnent ; une valeur négative signifie une victoire plus tôt avec B. Aucun ajustement des règles n'est appliqué.\n\n"
	text += "## Synthèse\n\n"
	text += table_header("Scénario / difficulté / choix")
	var groups: Dictionary = {}
	var starts: Dictionary = {}
	for pair in pairs:
		var key = "%s / %s / %s" % [pair.early.scenario, pair.early.difficulty, pair.choice]
		if not groups.has(key): groups[key] = []
		groups[key].append(pair)
		var start_key = key + " / " + pair.early.start
		if not starts.has(start_key): starts[start_key] = []
		starts[start_key].append(pair)
	for group in [groups, starts]:
		var keys = group.keys()
		keys.sort()
		for key in keys: text += table_row(key, summarize(group[key]))
		if group == groups: text += "\n## Par départ\n\n" + table_header("Scénario / difficulté / choix / départ")
	return text

static func table_header(label: String) -> String:
	return "| %s | Paires | A seul gagne | B seul gagne | Deux victoires | Deux défaites | Acquis A/B | Δ jours moyen |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n" % label

static func table_row(label: String, stats: Dictionary) -> String:
	var delta = "—" if stats.both == 0 else "%.2f" % (float(stats.win_day_delta) / stats.both)
	return "| %s | %d | %d | %d | %d | %d | %d/%d | %s |\n" % [label, stats.count, stats.early_only, stats.late_only, stats.both, stats.neither, stats.early_bought, stats.late_bought, delta]

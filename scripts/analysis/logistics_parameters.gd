extends RefCounted
## Offline, synchronous parameter experiments. Never save a hypothetical world.
const Comparison = preload("res://scripts/analysis/decision_comparison.gd")
const Decisions = preload("res://scripts/gameplay/decisions.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const RESERVE = 6

static func candidates() -> Dictionary:
	var result: Dictionary = {}
	for arm in ["disabled","observe","limit"]: result[arm] = {"arm":arm,"cost":6,"cure":1.15}
	for cost in [0,3,6]:
		for cure in [1.0,1.075,1.15]:
			result["support_c%d_r%d" % [cost,roundi(cure * 1000)]] = {"arm":"support","cost":cost,"cure":cure}
	return result

static func configure(id: String) -> String:
	if not candidates().has(id): return "Candidat inconnu."
	var definition = Decisions.definition()
	for choice in definition.choices:
		if choice.id == "support":
			choice.cost = candidates()[id].cost
			choice.cure = candidates()[id].cure
			choice.description = "Modèle expérimental : coût %d, mer ×1,50, remède ×%.3f, durée 12 jours." % [choice.cost,choice.cure]
	var error = Decisions.validate({"schema_version":1,"decision":definition})
	if error.is_empty(): Decisions._definition = definition
	return error

static func play(difficulty: String, seed_value: int, policy: String, id: String, limit: int = 500) -> Dictionary:
	if not candidates().has(id): return {"error":"Candidat inconnu."}
	var previous = Decisions._definition.duplicate(true)
	var error = configure(id)
	var row: Dictionary = {"error":error}
	if error.is_empty():
		row = Comparison.play(difficulty,seed_value,policy,candidates()[id].arm,"reserve",limit,RESERVE)
		if row.error.is_empty():
			row.candidate = id
			row.parameters = candidates()[id]
			row.model_hash = JSON.stringify(Decisions.definition(),"",true,true).sha256_text()
	# No await or early return may occur while the hypothetical catalogue is set.
	Decisions._definition = previous
	return row

static func validate_row(row: Dictionary) -> String:
	if not candidates().has(row.get("candidate")) or row.get("parameters") != candidates()[row.candidate] or row.get("reserve_floor") != RESERVE: return "Métadonnées expérimentales incohérentes."
	var previous = Decisions._definition.duplicate(true)
	var error = configure(row.candidate)
	if error.is_empty():
		if row.get("model_hash") != JSON.stringify(Decisions.definition(),"",true,true).sha256_text(): error = "Empreinte du modèle incohérente."
		elif row.get("arm") != candidates()[row.candidate].arm or row.get("funding") != "reserve": error = "Variante expérimentale incohérente."
		else: error = Comparison.validate_trace(row)
	Decisions._definition = previous
	return error

static func pair_rows(rows: Array) -> Dictionary:
	if rows.is_empty(): return {"error":"Cohorte vide."}
	var groups: Dictionary = {}
	for row in rows:
		if not row is Dictionary: return {"error":"Observation invalide."}
		for field in ["error","difficulty","seed","policy","scenario","start","days","coverage","cure","points","score","outcome","decision","objective","attempts","purchases","samples","decision_attempts","candidate","parameters","model_hash","arm","funding","reserve_floor","pre_hash","state_hash"]:
			if not row.has(field): return {"error":"Observation incomplète : " + field}
		if row.error != "" or row.difficulty not in ["easy","normal","hard"] or not row.seed is int or not Comparison.Arctic.policies().has(row.policy) or row.scenario != "degel2042" or row.start != "boreale" or not Comparison.World.Objectives.integer(row.days,29,500) or row.outcome not in ["victory","defeat_cure","defeat_extinction"]: return {"error":"Identité ou résultat invalide."}
		for field in ["attempts","purchases","samples","decision_attempts"]:
			if not row[field] is Array: return {"error":"Trace invalide."}
		if not row.decision is Dictionary or not row.objective is Dictionary: return {"error":"État invalide."}
		for field in ["state_hash","pre_hash"]:
			if not row[field] is String or row[field].length() != 64: return {"error":"Empreinte invalide."}
		var error = validate_row(row)
		if not error.is_empty(): return {"error":error}
		if row.arm == "support" and (row.decision.get("choice") != "support" or row.decision.day != 28): return {"error":"Soutien non appliqué au J28."}
		var key = JSON.stringify([row.difficulty,row.seed,row.policy])
		if not groups.has(key): groups[key] = {}
		if groups[key].has(row.candidate): return {"error":"Candidat dupliqué."}
		groups[key][row.candidate] = row
	var result: Array = []
	var keys = groups.keys()
	keys.sort()
	for key in keys:
		var group = groups[key]
		if group.size() != candidates().size(): return {"error":"Groupe de paramètres incomplet."}
		for id in candidates():
			if group[id].pre_hash != group.disabled.pre_hash: return {"error":"Dérive avant intervention."}
		for field in ["state_hash","outcome","days","coverage","cure","points","score","objective","purchases","attempts","samples"]:
			if group.disabled[field] != group.observe[field]: return {"error":"Dérive du maintien neutre."}
		result.append(group)
	return {"error":"","groups":result}

static func contrasts(groups: Array, candidate: String, reference: String) -> Dictionary:
	var pairs: Array = []
	for group in groups: pairs.append({"support":group[candidate],"disabled":group[reference]})
	return Comparison.contrasts(pairs,"reserve","support")

static func subset(rows: Array, id: String, difficulty: String = "") -> Array:
	return rows.filter(func(row): return row.candidate == id and (difficulty.is_empty() or row.difficulty == difficulty))

static func report(rows: Array, groups: Array) -> String:
	var text = "# Coût du soutien et contrepartie du remède — analyse %s\n\n" % ProjectSettings.get_setting("application/config/version")
	text += "Commande : `dev.ps1 BalanceParameters`. Moteur `%s` ; contenu distribué inchangé `%s`.\n\n" % [Engine.get_version_info().string,Store.new().content_hash()]
	text += "Dégel, Boréale, Relais activés, quinze politiques, trois difficultés, graines 7/42/2042. Douze modèles par groupe : trois témoins et neuf soutiens (coûts 0/3/6 × remède 1/1,075/1,15). Mer ×1,50, durée 12 jours, décision au J28. Même réserve de 6 points pour TOUS les modèles du J20 au J27 ; elle ne dépend pas du prix candidat. Aucun point offert ; le coût nul est un témoin diagnostique. Arrêt au résultat, limite 500 jours.\n\n"
	text += "Seuls coût et facteur remède du catalogue en mémoire changent, le temps d'un appel synchrone d'analyse, puis le catalogue original est restauré, y compris après erreur. Aucun JSON du jeu ni fichier joueur n'est modifié. Chaque observation porte ses paramètres et l'empreinte du modèle ; les états hypothétiques ne sont jamais enregistrés comme sauvegardes jouables. Les empreintes d'état permettent les comparaisons internes, elles ne prouvent pas la compatibilité des modèles hypothétiques.\n\n"
	text += "Budget et tentatives reconstruits sous les paramètres de chaque candidat. Tous les soutiens doivent être appliqués au J28 ; douze états préalables identiques ; maintien et désactivation strictement identiques hors décision/journal. Une différence de prix peut changer les achats après J28 : c'est une conséquence mesurée de la politique, pas un effet maritime isolé. À coût fixe, la variation du remède mesure la conséquence simulée de ce facteur. Comparer deux facteurs simultanément n'isole pas l'un d'eux.\n\n"
	text += "## Modèles et résultats\n\n" + Comparison.header()
	for id in candidates(): text += Comparison.table_row(id,subset(rows,id))
	text += "\n## Par difficulté\n\n" + Comparison.header()
	for difficulty in ["easy","normal","hard"]:
		for id in candidates(): text += Comparison.table_row(difficulty + " / " + id,subset(rows,id,difficulty))
	text += "\n## Contrastes à un paramètre\n\nΔ jours de victoire uniquement sur les paires à deux victoires ; Δ Relais uniquement sur celles à deux Relais réussis. Gains/pertes restent affichés séparément. Les achats retard/tôt/absents/ajouts comptent des acquisitions, pas des parties.\n\n| Candidat / référence | Groupes | Victoires gagnées/perdues | Relais gagnés/perdus | Deux victoires | Δ jours victoire | Deux Relais | Relais tôt/tard | Δ jours Relais | Achats retard/tôt/absents/ajouts |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"
	var comparisons: Array = [["support_c6_r1150","disabled"]]
	for cost in [0,3]: comparisons.append(["support_c%d_r1150" % cost,"support_c6_r1150"])
	for cost in [0,3,6]:
		for cure in [1000,1075]: comparisons.append(["support_c%d_r%d" % [cost,cure],"support_c%d_r1150" % cost])
	for pair in comparisons:
		var s = contrasts(groups,pair[0],pair[1])
		text += "| %s / %s | %d | %d/%d | %d/%d | %d | %s | %d | %d/%d | %s | %d/%d/%d/%d |\n" % [pair[0],pair[1],s.count,s.win_gain,s.win_loss,s.goal_gain,s.goal_loss,s.both_win,"—" if s.both_win == 0 else "%.2f" % (float(s.day_delta)/s.both_win),s.both_goal,s.goal_earlier,s.goal_later,"—" if s.both_goal == 0 else "%.2f" % (float(s.goal_day_delta)/s.both_goal),s.purchase_delays,s.purchase_earlier,s.purchase_missing,s.purchase_added]
	text += "\n## Remède à dates fixes\n\nChaque cellule donne la moyenne et le dénominateur observé. Les parties finies ne sont pas prolongées ; le remède final du premier tableau correspond à des jours différents.\n\n| Modèle | Jour | Observations | Remède moyen (%) |\n| --- | ---: | ---: | ---: |\n"
	for id in candidates():
		var s = Comparison.stats(subset(rows,id))
		for day in Comparison.SAMPLE_DAYS:
			if s.samples.has(day): text += "| %s | %d | %d | %.2f |\n" % [id,day,s.samples[day].count,s.samples[day].cure/s.samples[day].count]
	text += "\n## Paramètres exacts et empreintes\n\n| Modèle | Coût soutien | Facteur remède soutien | Empreinte catalogue hypothétique |\n| --- | ---: | ---: | --- |\n"
	for id in candidates(): text += "| %s | %d | %.3f | `%s` |\n" % [id,candidates()[id].cost,candidates()[id].cure,subset(rows,id)[0].model_hash]
	text += "\nLes modèles témoins conservent les paramètres 6/1,15 du soutien, mais ne choisissent pas ce soutien. Les politiques et traces complètes (achats, refus, points, choix, relevés) sont dans le JSON local. Trois graines et des politiques automatiques de même poids ne constituent pas une validation humaine. Les Relais sont plafonnés et figés. Décision d'ajustement et limites au point de reprise 16.\n"
	return text

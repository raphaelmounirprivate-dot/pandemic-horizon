extends RefCounted
## Compare complete, legal policies; no points or counterfactual effects are injected.
const World = preload("res://scripts/simulation/world.gd")
const Store = preload("res://scripts/persistence/save_store.gd")
const Arctic = preload("res://scripts/analysis/arctic_analysis.gd")
const ARMS = ["disabled","observe","support","limit"]
const FUNDING = ["ordinary","reserve"]
const SAMPLE_DAYS = [0,28,31,40,43,54]

static func fingerprint(world: RefCounted) -> String:
	var state = Store.new().encode(world)
	for key in ["saved_at","decision","decision_profile","journal"]: state.erase(key)
	return JSON.stringify(state,"",true,true).sha256_text()

static func sample(world: RefCounted) -> Dictionary:
	return {"day":world.day,"cure":world.cure,"coverage":world.coverage(),"points":world.points,"objective":world.objective.duplicate(true)}

static func play(difficulty: String, seed_value: int, policy: String, arm: String, funding: String, limit: int = 500, reserve_floor: int = 6) -> Dictionary:
	if arm not in ARMS or funding not in FUNDING or not Arctic.policies().has(policy) or difficulty not in ["easy","normal","hard"] or limit < 1 or limit > 500 or reserve_floor < 0 or reserve_floor > 100: return {"error":"Paramètres de comparaison invalides."}
	var world = World.new()
	var error = world.start("boreale",seed_value,null,null,"degel2042",difficulty,null,null,Arctic.ID,arm != "disabled")
	if not error.is_empty(): return {"error":error}
	var purchases: Array = []
	var attempts: Array = []
	var decisions: Array = []
	var samples: Array = [sample(world)]
	var pre_hash = ""
	var order = Arctic.policies()[policy]
	var cost = reserve_floor
	for i in range(limit):
		if world.day == 28: pre_hash = fingerprint(world)
		# Daily order: decision first, then first missing purchase, then daily step.
		if World.Decisions.pending(world):
			var before = world.points
			var choice_error = World.Decisions.choose(world,arm)
			decisions.append({"day":world.day,"before":before,"after":world.points,"error":choice_error})
		for id in order:
			if id in world.purchased: continue
			var before = world.points
			var reserve = funding == "reserve" and world.day >= 20 and world.day < 28
			var reason = world.purchase_reason(id)
			if reason.is_empty() and reserve and world.points - world.evolutions[id].cost < cost:
				reason = "Réserve de décision"
			elif reason.is_empty():
				reason = world.purchase(id)
				if reason.is_empty(): purchases.append({"id":id,"day":world.day,"before":before,"after":world.points})
			attempts.append({"id":id,"day":world.day,"before":before,"after":world.points,"reason":reason})
			break
		world.step()
		if world.day in SAMPLE_DAYS: samples.append(sample(world))
		if not world.outcome.is_empty(): break
	if world.outcome.is_empty(): return {"error":"Partie sans résultat avant la limite."}
	return {"error":"","scenario":"degel2042","start":"boreale","difficulty":difficulty,"seed":seed_value,"policy":policy,"arm":arm,"funding":funding,
		"outcome":world.outcome,"days":world.day,"coverage":world.coverage(),"cure":world.cure,"score":world.score(),"points":world.points,
		"objective":world.objective.duplicate(true),"decision":world.decision.duplicate(true),"decision_attempts":decisions,
		"purchases":purchases,"attempts":attempts,"samples":samples,"pre_hash":pre_hash,"state_hash":fingerprint(world),"reserve_floor":cost}

static func validate_trace(row: Dictionary) -> String:
	var world = World.new()
	world.start("boreale",row.seed,null,null,"degel2042",row.difficulty,null,null,Arctic.ID,row.arm != "disabled")
	var order = Arctic.policies()[row.policy]
	var purchases: Array = []
	var attempts: Array = []
	var decisions: Array = []
	# Replay only the budget/actions, not the population simulation. This checks
	# declined attempts as well as successful transactions against the real rules.
	for day in range(row.days):
		world.day = day
		if day > 0 and day % 5 == 0: world.points += 3
		World.Decisions.update(world)
		if World.Decisions.pending(world):
			var before = world.points
			var error = World.Decisions.choose(world,row.arm)
			decisions.append({"day":day,"before":before,"after":world.points,"error":error})
		for id in order:
			if id in world.purchased: continue
			var before = world.points
			var reason = world.purchase_reason(id)
			if reason.is_empty() and row.funding == "reserve" and day >= 20 and day < 28 and world.points - world.evolutions[id].cost < row.reserve_floor:
				reason = "Réserve de décision"
			elif reason.is_empty():
				reason = world.purchase(id)
				if reason.is_empty(): purchases.append({"id":id,"day":day,"before":before,"after":world.points})
			attempts.append({"id":id,"day":day,"before":before,"after":world.points,"reason":reason})
			break
	if row.days % 5 == 0: world.points += 3
	world.day = row.days
	world.outcome = row.outcome
	World.Decisions.update(world)
	if row.purchases != purchases or row.attempts != attempts or row.decision_attempts != decisions or row.points != world.points or row.decision != world.decision: return "Chronologie ou budget incohérents."
	if not World.Objectives.valid_state(row.objective,world) or not World.Decisions.valid_state(row.decision,world): return "État final incohérent."
	for field in ["coverage","cure"]:
		if not (row[field] is int or row[field] is float) or not is_finite(float(row[field])) or row[field] < 0 or row[field] > (1 if field == "coverage" else 100): return "Mesure hors bornes."
	if (row.outcome == "victory" and (row.coverage < 0.9 or row.cure >= 100)) or (row.outcome == "defeat_cure" and row.cure != 100): return "Résultat contradictoire."
	var expected_days = SAMPLE_DAYS.filter(func(day): return day <= row.days)
	if row.samples.size() != expected_days.size(): return "Relevé manquant."
	for index in range(expected_days.size()):
		var point = row.samples[index]
		if not point is Dictionary or point.get("day") != expected_days[index]: return "Date de relevé incohérente."
		for field in ["coverage","cure"]:
			if not (point.get(field) is int or point.get(field) is float) or not is_finite(float(point[field])) or point[field] < 0 or point[field] > (1 if field == "coverage" else 100): return "Relevé hors bornes."
	return ""

static func pair_rows(rows: Array) -> Dictionary:
	if rows.is_empty(): return {"error":"Cohorte vide."}
	var groups: Dictionary = {}
	for row in rows:
		if not row is Dictionary: return {"error":"Observation invalide."}
		for key in ["error","scenario","start","difficulty","seed","policy","arm","funding","outcome","days","coverage","cure","score","points","objective","decision","decision_attempts","purchases","attempts","samples","pre_hash","state_hash","reserve_floor"]:
			if not row.has(key): return {"error":"Observation incomplète : " + key}
		if row.error != "" or row.scenario != "degel2042" or row.start != "boreale" or row.difficulty not in ["easy","normal","hard"] or not row.seed is int or not Arctic.policies().has(row.policy) or row.arm not in ARMS or row.funding not in FUNDING: return {"error":"Identité invalide."}
		if not World.Objectives.integer(row.reserve_floor,0,100): return {"error":"Réserve invalide."}
		if not World.Objectives.integer(row.days,1,500) or row.outcome not in ["victory","defeat_cure","defeat_extinction"] or not row.objective is Dictionary or not row.decision is Dictionary: return {"error":"Résultat invalide."}
		if row.objective.get("id") != Arctic.ID or row.objective.get("status") not in ["completed","failed"]: return {"error":"Objectif non résolu."}
		for field in ["purchases","attempts","samples","decision_attempts"]:
			if not row[field] is Array: return {"error":"Trace invalide."}
		for field in ["pre_hash","state_hash"]:
			if not row[field] is String or row[field].length() != 64: return {"error":"Empreinte invalide."}
		if row.arm == "disabled" and not row.decision.is_empty(): return {"error":"Témoin avec décision."}
		if row.arm != "disabled" and row.decision.get("choice") not in [row.arm,"observe"]: return {"error":"Choix différent de la politique."}
		var trace_error = validate_trace(row)
		if not trace_error.is_empty(): return {"error":trace_error}
		var key = JSON.stringify([row.difficulty,row.seed,row.policy,row.funding])
		if not groups.has(key): groups[key] = {}
		if groups[key].has(row.arm): return {"error":"Observation dupliquée."}
		groups[key][row.arm] = row
	var pairs: Array = []
	var keys = groups.keys()
	keys.sort()
	for key in keys:
		var group = groups[key]
		if group.size() != ARMS.size(): return {"error":"Groupe incomplet."}
		for arm in ARMS:
			if group[arm].pre_hash != group.disabled.pre_hash: return {"error":"Dérive avant décision."}
		for field in ["state_hash","outcome","days","coverage","cure","score","points","objective","purchases","attempts","samples"]:
			if group.disabled[field] != group.observe[field]: return {"error":"Dérive du maintien neutre : " + field}
		if group.support.funding == "reserve" and group.support.decision.get("choice") != "support": return {"error":"Réserve sans soutien effectif."}
		pairs.append(group)
	return {"error":"","groups":pairs}

static func stats(rows: Array) -> Dictionary:
	var result = {"count":rows.size(),"wins":0,"goals":0,"both":0,"goal_only":0,"win_only":0,"neither":0,"selected":0,"cost":0,"cure":0.0,"days":0,"choice_days":[],"samples":{}}
	for row in rows:
		var win = row.outcome == "victory"
		var goal = row.objective.status == "completed"
		if win: result.wins += 1
		if goal: result.goals += 1
		if win and goal: result.both += 1
		elif goal: result.goal_only += 1
		elif win: result.win_only += 1
		else: result.neither += 1
		if row.arm != "disabled" and row.decision.choice == row.arm:
			result.selected += 1
			result.choice_days.append(row.decision.day)
		if row.decision.get("choice") == "support": result.cost += World.Decisions.option("support").cost
		result.cure += row.cure
		result.days += row.days
		for point in row.samples:
			if not result.samples.has(point.day): result.samples[point.day] = {"count":0,"cure":0.0}
			result.samples[point.day].count += 1
			result.samples[point.day].cure += point.cure
	return result

static func header() -> String:
	return "| Série / variante | Parties | Victoires | Relais réussis | Deux succès | Relais seuls | Victoire seule | Deux échecs | Choix demandé appliqué | Remède final moyen | Jour final moyen |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n"

static func table_row(label: String, rows: Array) -> String:
	if rows.is_empty(): return ""
	var s = stats(rows)
	return "| %s | %d | %d | %d | %d | %d | %d | %d | %s | %.2f | %.2f |\n" % [label,s.count,s.wins,s.goals,s.both,s.goal_only,s.win_only,s.neither,"—" if rows[0].arm == "disabled" else str(s.selected),s.cure/s.count,float(s.days)/s.count]

static func select(rows: Array, funding: String, arm: String, difficulty: String = "") -> Array:
	return rows.filter(func(row): return row.funding == funding and row.arm == arm and (difficulty.is_empty() or row.difficulty == difficulty))

static func contrasts(groups: Array, funding: String, arm: String) -> Dictionary:
	var result = {"count":0,"win_gain":0,"win_loss":0,"goal_gain":0,"goal_loss":0,"both_win":0,"day_delta":0,"both_goal":0,"goal_day_delta":0,"goal_earlier":0,"goal_later":0,"purchase_delays":0,"purchase_earlier":0,"purchase_missing":0,"purchase_added":0}
	for group in groups:
		if group.disabled.funding != funding: continue
		var a = group[arm]
		var b = group.disabled
		result.count += 1
		if a.outcome == "victory" and b.outcome != "victory": result.win_gain += 1
		if a.outcome != "victory" and b.outcome == "victory": result.win_loss += 1
		if a.objective.status == "completed" and b.objective.status != "completed": result.goal_gain += 1
		if a.objective.status != "completed" and b.objective.status == "completed": result.goal_loss += 1
		if a.objective.status == "completed" and b.objective.status == "completed":
			result.both_goal += 1
			result.goal_day_delta += a.objective.resolved_day - b.objective.resolved_day
			if a.objective.resolved_day < b.objective.resolved_day: result.goal_earlier += 1
			if a.objective.resolved_day > b.objective.resolved_day: result.goal_later += 1
		if a.outcome == "victory" and b.outcome == "victory":
			result.both_win += 1
			result.day_delta += a.days - b.days
		var dates: Dictionary = {}
		for purchase in b.purchases: dates[purchase.id] = purchase.day
		for purchase in a.purchases:
			if not dates.has(purchase.id): result.purchase_added += 1
			else:
				if purchase.day > dates[purchase.id]: result.purchase_delays += 1
				elif purchase.day < dates[purchase.id]: result.purchase_earlier += 1
				dates.erase(purchase.id)
		result.purchase_missing += dates.size()
	return result

static func report(rows: Array, groups: Array) -> String:
	var text = "# Décision logistique — analyse du prototype %s\n\n" % ProjectSettings.get_setting("application/config/version")
	text += "Moteur : `%s`. Empreinte du contenu : `%s`.\n\n" % [Engine.get_version_info().string,Store.new().content_hash()]
	text += "Commande : `dev.ps1 BalanceDecisions`. Dégel, Boréale, Relais arctiques activés ; trois difficultés, graines 7/42/2042, quinze ordres historiques. Quatre variantes par groupe : désactivée (`disabled`), maintien (`observe`), soutien (`support`), limitation (`limit`). Arrêt au résultat principal, limite 500 jours.\n\n"
	text += "Deux séries : `ordinary`, achats habituels ; `reserve`, même restriction dans les quatre variantes du J20 au J27 : ne pas acheter si le solde passerait sous 6 points. Aucun point offert. Au début de chaque journée : tenter le choix demandé s'il est en attente, puis le premier achat manquant de l'ordre, puis simuler. Choix au J28 si abordable, sinon nouvelle tentative J29/J30 ; au J31, maintien automatique. Une intention de soutien n'est pas un soutien appliqué. La réserve peut modifier les dates avant J28 ; comparer les variantes à l'intérieur de leur série.\n\n"
	text += "Les empreintes avant choix doivent être identiques pour les quatre variantes. Maintien et désactivation doivent avoir les mêmes états complets, résultats, achats et échantillons, hors décision et journal. Les autres variantes peuvent changer budget, achats, propagation, objectifs et fin. Groupes manquants/dupliqués et dérives font échouer la commande. Le CSV conserve tentatives, refus, achats et points avant/après, choix réellement appliqué, relevés datés, RNG inclus dans les empreintes.\n\n"
	text += "## Ensemble\n\n" + header()
	for funding in FUNDING:
		for arm in ARMS: text += table_row(funding + " / " + arm,select(rows,funding,arm))
	text += "\n## Par difficulté\n\n" + header()
	for funding in FUNDING:
		for difficulty in ["easy","normal","hard"]:
			for arm in ARMS: text += table_row(funding + " / " + difficulty + " / " + arm,select(rows,funding,arm,difficulty))
	text += "\n## Par politique\n\n" + header()
	for funding in FUNDING:
		for policy in Arctic.policies():
			for arm in ARMS:
				text += table_row(funding + " / " + policy + " / " + arm,select(rows,funding,arm).filter(func(row): return row.policy == policy))
	text += "\n## Contrastes appariés avec désactivation\n\nΔ jours = variante − témoin, uniquement quand les deux gagnent. Les gains et pertes comptent des changements de résultat dans les mêmes groupes. Les colonnes achats comptent des acquisitions, pas des parties : en retard / plus tôt / absentes / supplémentaires par rapport au témoin.\n\n| Série / variante | Groupes | Victoires gagnées/perdues | Relais gagnés/perdus | Deux victoires | Δ jours moyen | Achats retard/tôt/absents/ajouts |\n| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n"
	for funding in FUNDING:
		for arm in ["observe","support","limit"]:
			var s = contrasts(groups,funding,arm)
			text += "| %s / %s | %d | %d/%d | %d/%d | %d | %s | %d/%d/%d/%d |\n" % [funding,arm,s.count,s.win_gain,s.win_loss,s.goal_gain,s.goal_loss,s.both_win,"—" if s.both_win == 0 else "%.2f" % (float(s.day_delta)/s.both_win),s.purchase_delays,s.purchase_earlier,s.purchase_missing,s.purchase_added]
	text += "\n## Date des Relais dans les paires à deux réussites\n\nLes échecs sont exclus de ces dates, mais restent dans la table des gains/pertes ci-dessus. Une avance de relais ne signifie pas une victoire principale.\n\n| Série / variante | Deux relais réussis | Relais plus tôt | Relais plus tard | Δ jour moyen |\n| --- | ---: | ---: | ---: | ---: |\n"
	for funding in FUNDING:
		for arm in ["observe","support","limit"]:
			var s = contrasts(groups,funding,arm)
			text += "| %s / %s | %d | %d | %d | %s |\n" % [funding,arm,s.both_goal,s.goal_earlier,s.goal_later,"—" if s.both_goal == 0 else "%.2f" % (float(s.goal_day_delta)/s.both_goal)]
	text += "\n## Choix réellement appliqués\n\n| Série / choix demandé | Appliqué | Jour min–max | Points dépensés au total | Maintien automatique faute de financement |\n| --- | ---: | ---: | ---: | ---: |\n"
	for funding in FUNDING:
		for arm in ["observe","support","limit"]:
			var s = stats(select(rows,funding,arm))
			text += "| %s / %s | %d/%d | %s | %d | %d |\n" % [funding,arm,s.selected,s.count,"—" if s.choice_days.is_empty() else "%d–%d" % [s.choice_days.min(),s.choice_days.max()],s.cost,s.count - s.selected]
	text += "\n## Progression du remède\n\nMoyenne au même jour et nombre de parties observées. Une partie déjà terminée n'est pas prolongée artificiellement ; si les dénominateurs diffèrent, les moyennes ne sont pas des contrastes appariés. Le remède final se mesure à des jours différents, selon la fin principale.\n\n| Série / variante | Jour | Observations | Remède moyen (%) |\n| --- | ---: | ---: | ---: |\n"
	for funding in FUNDING:
		for arm in ARMS:
			var s = stats(select(rows,funding,arm))
			for day in SAMPLE_DAYS:
				if s.samples.has(day): text += "| %s / %s | %d | %d | %.2f |\n" % [funding,arm,day,s.samples[day].count,s.samples[day].cure/s.samples[day].count]
	text += "\n## Dates des achats\n\nAcquis avant la fin principale ; échéance incluse J54. Dates min–max des seules acquisitions, sans inventer de date pour un achat absent.\n\n| Série / variante / achat | Parties | Acquis | Avant J54 inclus | Jour min–max |\n| --- | ---: | ---: | ---: | ---: |\n"
	for funding in FUNDING:
		for arm in ARMS:
			var subset = select(rows,funding,arm)
			for id in ["transmission","mobility","discretion","land_network","air_bridge","sea_logistics","polar","seasonal","resilience"]:
				var acquired = 0
				var timely = 0
				var first = 500
				var last = 0
				for row in subset:
					for purchase in row.purchases:
						if purchase.id != id: continue
						acquired += 1
						if purchase.day <= 54: timely += 1
						first = mini(first,purchase.day)
						last = maxi(last,purchase.day)
				text += "| %s / %s / %s | %d | %d | %d | %s |\n" % [funding,arm,id,subset.size(),acquired,timely,"—" if acquired == 0 else "%d–%d" % [first,last]]
	text += "\n## Politiques\n\n"
	for policy in Arctic.policies(): text += "- `%s` : %s.\n" % [policy,"aucun achat" if Arctic.policies()[policy].is_empty() else " → ".join(Arctic.policies()[policy])]
	text += "\nLes quinze politiques ont le même poids ; trois graines seulement, plusieurs dates peuvent se répéter. Ces résultats décrivent des politiques automatiques complètes et les coefficients 0.11, pas des joueurs humains ni un effet causal isolé de chaque facteur. Les compteurs arctiques sont plafonnés et figés ; ils ne mesurent pas le trafic total. La décision d'ajustement et ses limites sont consignées dans le point de reprise 15.\n"
	return text

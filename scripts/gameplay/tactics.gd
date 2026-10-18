extends RefCounted
const PATH = "res://data/tactics.json"
const PROFILE = "tactics-0.22"
static func rules() -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data if data is Dictionary else {}
static func validate() -> String:
	var data = rules()
	if data.get("schema_version") != 1 or data.get("profile") != PROFILE or data.get("targeting") != "active_and_healthy_at_activation": return "Profil réactif invalide."
	if not data.get("response") is Dictionary or not data.response.get("choices") is Array or data.response.choices.size() != 3: return "Réponses de crise invalides."
	if data.response.get("template") != "communications" or data.response.get("window") != 3 or data.response.get("duration") != 6: return "Calendrier de réponse invalide."
	var ids: Array = []
	for choice in data.response.choices:
		if not choice is Dictionary or choice.get("id") not in ["detour","endure","opportunity"] or choice.id in ids: return "Réponse inconnue ou dupliquée."
		for key in ["name","description"]:
			if not choice.get(key) is String or choice[key].is_empty(): return "Description de réponse invalide."
		if not integer(choice.get("cost"),0,20): return "Coût de réponse invalide."
		for key in ["air","cure"]:
			if not (choice.get(key) is float or choice.get(key) is int) or not is_finite(float(choice[key])) or choice[key] < 1 or choice[key] > 2: return "Coefficient de réponse invalide."
		if choice.id == "endure" and (choice.cost != 0 or choice.air != 1 or choice.cure != 1): return "La réponse neutre doit rester gratuite."
		ids.append(choice.id)
	if not data.get("goal") is Dictionary or data.goal.get("source") != "centrale" or data.goal.get("targets") != ["meridien","savane"] or data.goal.get("scenario") != "fragile2042" or data.goal.get("quota") != 6000 or data.goal.get("deadline") != 60: return "Objectif réseau invalide."
	return ""
static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= minimum and value <= maximum
static func initial(scenario_id: String) -> Dictionary:
	return {"targets":{},"response":{},"goal":{"status":"pending","meridien":0,"savane":0,"resolved_day":-1} if scenario_id == "fragile2042" else {}}
static func resolve_target(world, definition: Dictionary) -> Dictionary:
	var event = definition.duplicate(true)
	if not world.tactics_enabled or event.get("source") != "crisis" or event.kind != "growth_multiplier": return event
	var candidates = world.regions.filter(func(r): return r.active > 0 and r.healthy > 0)
	if not candidates.is_empty():
		var random = RandomNumberGenerator.new()
		random.seed = world.rng.seed ^ int(event.id.hash()) ^ (world.day*97)
		event.target = candidates[random.randi_range(0,candidates.size()-1)].id
		world.journal.append("Jour %d · Ciblage régional réactif : %s (foyer actif, population encore saine)." % [world.day,world.region_name(event.target)])
	else: world.journal.append("Jour %d · Aucun foyer éligible : cible régionale initiale conservée." % world.day)
	world.tactics.targets[event.id] = event.target
	# Keep the resolved definition for this world; later saves retain it explicitly.
	for item in world.event_definitions:
		if item.id == event.id: item.target = event.target
	return event
static func on_event(world, event: Dictionary) -> void:
	if not world.tactics_enabled or event.get("template") != "communications" or not world.tactics.response.is_empty(): return
	world.tactics.response = {"status":"queued","event":event.id,"opened":-1,"choice":"","day":-1,"reason":""}
static func pending(world) -> bool:
	return world.tactics_enabled and world.tactics.response.get("status") == "pending"
static func option(id: String) -> Dictionary:
	for choice in rules().get("response",{}).get("choices",[]):
		if choice.id == id: return choice
	return {}
static func reason(world,id: String) -> String:
	if not pending(world) or not world.outcome.is_empty(): return "Réponse indisponible."
	var choice = option(id)
	if choice.is_empty(): return "Réponse inconnue."
	if world.points < choice.cost: return "Points insuffisants : %d requis." % choice.cost
	return ""
static func choose(world,id: String,automatic: String = "") -> String:
	if automatic not in ["","timeout","game_over"] or (automatic != "" and id != "endure"): return "Choix automatique invalide."
	if not pending(world) and not (automatic == "game_over" and world.tactics.response.get("status") == "queued"): return "Réponse indisponible."
	if automatic == "" and not reason(world,id).is_empty(): return reason(world,id)
	if automatic == "timeout" and world.day != int(world.tactics.response.opened)+3: return "Échéance non atteinte."
	if automatic == "game_over" and world.outcome.is_empty(): return "Partie en cours."
	var choice = option(id)
	if choice.is_empty(): return "Réponse inconnue."
	world.points -= int(choice.cost)
	world.tactics.response.choice = id
	world.tactics.response.day = world.day
	world.tactics.response.reason = "manual" if automatic.is_empty() else automatic
	world.tactics.response.status = "resolved" if id == "endure" else "active"
	world.journal.append("Jour %d · Crise : %s (%d points). %s" % [world.day,choice.name,choice.cost,choice.description])
	world.History.record(world)
	return ""
static func update(world) -> void:
	if not world.tactics_enabled: return
	var response = world.tactics.response
	if response.is_empty(): return
	if not world.outcome.is_empty() and response.status in ["pending","queued"]:
		choose(world,"endure","game_over")
		return
	if response.status == "queued" and not world.Decisions.pending(world):
		response.status = "pending"
		response.opened = world.day
		world.journal.append("Jour %d · Panne aérienne : réponse possible jusqu'au J%d inclus [F2]." % [world.day,world.day+2])
	if response.status == "pending" and world.day >= int(response.opened)+3: choose(world,"endure","timeout")
	if response.status == "active" and world.day > int(response.day)+6:
		response.status = "expired"
		world.journal.append("Jour %d · Fin des effets de la réponse à la panne." % world.day)
static func modifier(world,kind: String,target: String) -> float:
	if not world.tactics_enabled or world.tactics.response.get("status") != "active": return 1.0
	var response = world.tactics.response
	if world.day <= response.day or world.day > response.day+6: return 1.0
	var choice = option(response.choice)
	if kind == "transport_multiplier" and target == "air": return float(choice.air)
	if kind == "cure_multiplier" and target == "global": return float(choice.cure)
	return 1.0
static func record_exchange(world,from: String,to: String,units: int) -> void:
	if not world.tactics_enabled or world.tactics.goal.is_empty() or world.tactics.goal.status != "pending" or world.day > 60 or from != "centrale" or to not in ["meridien","savane"]: return
	world.tactics.goal[to] = mini(6000,int(world.tactics.goal[to])+units)
static func update_goal(world) -> void:
	if not world.tactics_enabled or world.tactics.goal.is_empty() or world.tactics.goal.status != "pending": return
	var goal = world.tactics.goal
	if goal.meridien >= 6000 and goal.savane >= 6000:
		goal.status = "completed"
	elif world.day >= 60: goal.status = "failed"
	else: return
	goal.resolved_day = world.day
	world.journal.append("Jour %d · Double relais : %s." % [world.day,"réussi" if goal.status == "completed" else "échéance manquée"])
static func goal_summary(world) -> String:
	if not world.tactics_enabled or world.tactics.goal.is_empty(): return ""
	var goal = world.tactics.goal
	return "Double relais obligatoire · Méridien %d/6000 · Savane %d/6000 · J60 inclus · %s" % [goal.meridien,goal.savane,{"pending":"en cours","completed":"réussi","failed":"échoué"}[goal.status]]
static func summary(world) -> String:
	if not world.tactics_enabled or world.tactics.response.is_empty(): return ""
	var response = world.tactics.response
	if response.status == "queued": return "Réponse à la panne en attente de la décision logistique prioritaire."
	if response.status == "pending": return "Panne aérienne · Choisir avant J%d inclus [F2]." % (int(response.opened)+2)
	var text = "Réponse : " + option(response.choice).name
	if response.status == "active": text += " · Effets J%d à J%d inclus." % [int(response.day)+1,int(response.day)+6]
	elif response.status == "expired": text += " · Effets terminés."
	return text
static func restore(world,data: Variant,outcome: String) -> bool:
	if not data is Dictionary or data.size() != 3 or not data.get("targets") is Dictionary or not data.get("response") is Dictionary or not data.get("goal") is Dictionary: return false
	var definitions: Dictionary = {}
	for event in world.event_definitions: definitions[event.id] = event
	for id in data.targets:
		if not definitions.has(id) or definitions[id].get("source") != "crisis" or definitions[id].kind != "growth_multiplier" or definitions[id].start_day > world.day: return false
		if not data.targets[id] is String or not world.regions.any(func(r): return r.id == data.targets[id]): return false
		definitions[id].target = data.targets[id]
	for event in world.event_definitions:
		if event.get("source") == "crisis" and event.kind == "growth_multiplier" and event.start_day <= world.day and not data.targets.has(event.id): return false
	var r = data.response
	var trigger: Dictionary = {}
	for event in world.event_definitions:
		if event.get("template") == "communications" and (trigger.is_empty() or event.start_day < trigger.start_day): trigger = event
	if r.is_empty():
		if not trigger.is_empty() and trigger.start_day <= world.day: return false
	else:
		if r.size() != 6 or trigger.is_empty() or r.get("event") != trigger.id or trigger.start_day > world.day: return false
		if r.get("status") not in ["queued","pending","active","expired","resolved"] or not integer(r.get("opened"),-1,world.day) or not integer(r.get("day"),-1,world.day): return false
		if not r.get("choice") is String or not r.get("reason") is String: return false
		if r.status in ["queued","pending"]:
			if r.choice != "" or r.day != -1 or r.reason != "" or not outcome.is_empty(): return false
			if r.status == "queued" and r.opened != -1: return false
			if r.status == "pending" and (r.opened < trigger.start_day or world.day >= r.opened+3): return false
		else:
			if option(r.choice).is_empty() or r.reason not in ["manual","timeout","game_over"]: return false
			if r.day < trigger.start_day: return false
			if r.reason == "manual" and (r.opened < trigger.start_day or r.day < r.opened or r.day >= r.opened+3): return false
			if r.reason == "timeout" and (r.choice != "endure" or r.day != r.opened+3): return false
			if r.reason == "game_over" and (r.choice != "endure" or outcome.is_empty() or r.day != world.day): return false
			if r.choice == "endure" and r.status != "resolved": return false
			if r.choice != "endure" and r.status != ("expired" if world.day > r.day+6 else "active"): return false
	var goal = data.goal
	if world.scenario.id != "fragile2042":
		if not goal.is_empty(): return false
	else:
		if goal.size() != 4 or goal.get("status") not in ["pending","completed","failed"] or not integer(goal.get("meridien"),0,6000) or not integer(goal.get("savane"),0,6000) or not integer(goal.get("resolved_day"),-1,mini(60,world.day)): return false
		if goal.status == "pending" and (goal.resolved_day != -1 or world.day >= 60 or (goal.meridien == 6000 and goal.savane == 6000)): return false
		if goal.status == "completed" and (goal.resolved_day < 1 or goal.meridien != 6000 or goal.savane != 6000): return false
		if goal.status == "failed" and (goal.resolved_day != 60 or world.day < 60 or (goal.meridien == 6000 and goal.savane == 6000)): return false
	world.tactics = data.duplicate(true)
	for key in ["opened","day"]:
		if not world.tactics.response.is_empty(): world.tactics.response[key] = int(world.tactics.response[key])
	if not goal.is_empty():
		for key in ["meridien","savane","resolved_day"]: world.tactics.goal[key] = int(world.tactics.goal[key])
	return true
static func spent(world) -> int:
	if not world.tactics_enabled or world.tactics.response.get("choice","").is_empty(): return 0
	return int(option(world.tactics.response.choice).cost)

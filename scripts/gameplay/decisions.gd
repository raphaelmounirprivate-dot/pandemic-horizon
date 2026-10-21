extends RefCounted
const Objectives = preload("res://scripts/gameplay/objectives.gd")
static var _definition: Dictionary = {}

static func validate(data: Variant) -> String:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("decision") is Dictionary: return "Catalogue de décisions invalide."
	var item: Variant = data.decision
	if item.get("id") != "arctic_logistics" or item.get("scenario") != "degel2042" or item.get("phase") != "instability" or not item.get("name") is String: return "Référence de décision invalide."
	if not Objectives.integer(item.get("start_day"),1,500) or not Objectives.integer(item.get("expires_day"),int(item.start_day) + 1,501): return "Fenêtre de décision invalide."
	if not item.get("choices") is Array or item.choices.size() != 3: return "Choix de décision invalides."
	var ids: Array = []
	for choice: Variant in item.choices:
		if not choice is Dictionary or choice.get("id") not in ["support","limit","observe"] or choice.id in ids: return "Choix inconnu ou dupliqué."
		for key: String in ["name","description"]:
			if not choice.get(key) is String or choice[key].is_empty() or choice[key].length() > 300: return "Texte de choix invalide."
		if not Objectives.integer(choice.get("cost"),0,100) or not Objectives.integer(choice.get("duration"),0,100): return "Coût ou durée de choix invalide."
		for key: String in ["sea","cure"]:
			if not (choice.get(key) is int or choice.get(key) is float) or not is_finite(float(choice[key])) or choice[key] < 0.1 or choice[key] > 3: return "Coefficient de choix invalide."
		if choice.id == "observe" and (choice.cost != 0 or choice.duration != 0 or choice.sea != 1 or choice.cure != 1): return "Le choix neutre doit rester gratuit et sans effet."
		if choice.id != "observe" and choice.duration < 1: return "Effet sans durée."
		ids.append(choice.id)
	return ""

static func definition(world: RefCounted = null) -> Dictionary:
	if world != null and not world.decision_rules.is_empty(): return world.decision_rules.duplicate(true)
	if _definition.is_empty():
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/decisions.json"))
		if not validate(data).is_empty(): return {}
		_definition = data.decision
	return _definition.duplicate(true)

static func legacy_definition() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/decisions-0.11.json"))
	return data.decision.duplicate(true) if validate(data).is_empty() else {}

static func option(id: String, world: RefCounted = null) -> Dictionary:
	for choice: Dictionary in definition(world).get("choices",[]):
		if choice.id == id: return choice
	return {}

static func initial(enabled: bool) -> Dictionary:
	return {"status":"scheduled","choice":"","day":-1,"reason":""} if enabled else {}

static func pending(world: RefCounted) -> bool:
	return world.decision.get("status") == "pending"

static func reason(world: RefCounted, id: String) -> String:
	if not pending(world) or not world.outcome.is_empty(): return "Décision indisponible."
	var choice: Dictionary = option(id,world)
	if choice.is_empty(): return "Choix inconnu."
	if world.points < choice.cost: return "Points insuffisants : %d requis, %d disponibles." % [choice.cost,world.points]
	return ""

static func choose(world: RefCounted, id: String, source: String = "manual") -> String:
	if source not in ["manual","timeout","game_over"] or (source != "manual" and id != "observe"): return "Choix automatique invalide."
	if not pending(world) or option(id).is_empty(): return "Décision indisponible."
	if source == "timeout" and world.day != definition(world).expires_day: return "Échéance non atteinte."
	if source == "game_over" and world.outcome.is_empty(): return "Partie non terminée."
	var error: String = reason(world,id)
	if not error.is_empty() and source == "manual": return error
	var choice: Dictionary = option(id,world)
	world.points -= int(choice.cost)
	world.decision = {"status":"resolved" if choice.duration == 0 else "active","choice":id,"day":world.day,"reason":source}
	world.journal.append("Jour %d · Décision : %s (%d points). %s" % [world.day,choice.name,choice.cost,choice.description])
	return ""

static func update(world: RefCounted) -> void:
	if world.decision.is_empty(): return
	var item: Dictionary = definition(world)
	if world.decision.status == "scheduled" and world.day >= item.start_day:
		world.decision.status = "pending"
		world.journal.append("Jour %d · %s : décision possible jusqu'au jour %d inclus." % [world.day,item.name,item.expires_day - 1])
	if pending(world) and world.day >= item.expires_day: choose(world,"observe","timeout")
	if world.decision.status == "active" and world.day > world.decision.day + option(world.decision.choice,world).duration:
		world.decision.status = "expired"
		world.journal.append("Jour %d · Fin des effets de la décision logistique." % world.day)
	if not world.outcome.is_empty():
		if pending(world): choose(world,"observe","game_over")
		elif world.decision.status == "scheduled": world.decision = {"status":"cancelled","choice":"","day":world.day,"reason":"game_over"}

static func modifier(world: RefCounted, kind: String, target: String) -> float:
	if world.decision.get("status") != "active": return 1.0
	var choice: Dictionary = option(world.decision.choice,world)
	if world.day <= world.decision.day or world.day > world.decision.day + choice.duration: return 1.0
	if kind == "transport_multiplier" and target == "sea": return float(choice.sea)
	if kind == "cure_multiplier" and target == "global": return float(choice.cure)
	return 1.0

static func summary(world: RefCounted) -> String:
	if world.decision.is_empty(): return "Décision logistique désactivée."
	match world.decision.status:
		"scheduled": return "Décision logistique prévue au J%d." % definition(world).start_day
		"pending": return "Logistique sous tension · Choisir avant J%d inclus [F2]." % (definition(world).expires_day - 1)
		"cancelled": return "Décision logistique annulée : partie terminée."
	var choice: Dictionary = option(world.decision.choice,world)
	var text: String = "Décision : " + choice.name
	if world.decision.status == "active": text += " · Effets J%d à J%d inclus." % [world.decision.day + 1,world.decision.day + choice.duration]
	elif world.decision.status == "expired": text += " · Effets terminés."
	else: text += " · Sans effet supplémentaire."
	return text

static func valid_state(state: Variant, world: RefCounted) -> bool:
	if not state is Dictionary: return false
	if state.is_empty(): return true
	if state.size() != 4 or world.scenario.id != "degel2042": return false
	for key: String in ["status","choice","day","reason"]:
		if not state.has(key): return false
	if not Objectives.integer(state.day,-1,world.day): return false
	var item: Dictionary = definition(world)
	match state.status:
		"scheduled": return state.choice == "" and state.day == -1 and state.reason == "" and world.day < item.start_day and world.outcome.is_empty()
		"pending": return state.choice == "" and state.day == -1 and state.reason == "" and world.day >= item.start_day and world.day < item.expires_day and world.outcome.is_empty()
		"cancelled": return state.choice == "" and state.day == world.day and state.reason == "game_over" and world.day < item.start_day and not world.outcome.is_empty()
	var choice: Dictionary = option(str(state.choice),world)
	if choice.is_empty(): return false
	if state.reason == "manual":
		if state.day < item.start_day or state.day >= item.expires_day: return false
	elif state.reason == "timeout":
		if state.day != item.expires_day or choice.id != "observe": return false
	elif state.reason == "game_over":
		if state.day != world.day or choice.id != "observe" or world.outcome.is_empty() or state.day < item.start_day or state.day >= item.expires_day: return false
	else: return false
	if state.status == "resolved": return choice.duration == 0
	if state.status == "active": return choice.duration > 0 and world.day <= state.day + choice.duration
	if state.status == "expired": return choice.duration > 0 and world.day > state.day + choice.duration
	return false

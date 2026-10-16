extends RefCounted
## Optional observation only: never modifies population, points, score or RNG.
const PATH = "res://data/objectives.json"

static func catalog() -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))

static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= low and value <= high

static func validate(data: Variant) -> String:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("objectives") is Array: return "Catalogue d'objectifs invalide."
	var ids: Array = []
	for item in data.objectives:
		if not item is Dictionary: return "Objectif invalide."
		if not item.get("id") is String or item.id.is_empty() or item.id in ids: return "Identifiant d'objectif invalide."
		if not item.get("name") is String or item.name.is_empty() or item.name.length() > 80: return "Nom d'objectif invalide."
		if item.get("scenario") != "standard": return "Scénario d'objectif invalide."
		if not integer(item.get("regions"), 1, 24) or not integer(item.get("coverage_percent"), 1, 100) or not integer(item.get("deadline"), 1, 500): return "Seuil d'objectif invalide."
		ids.append(item.id)
	return ""

static func definition(id: String) -> Dictionary:
	var data = catalog()
	if not validate(data).is_empty(): return {}
	for item in data.objectives:
		if item.id == id: return item
	return {}

static func count(world: RefCounted, item: Dictionary) -> int:
	var total = 0
	for region in world.regions:
		if (region.active + region.removed) * 100 >= region.population * item.coverage_percent: total += 1
	return mini(total, int(item.regions))

static func initial(id: String) -> Dictionary:
	return {} if id.is_empty() else {"id":id, "status":"pending", "progress":0, "resolved_day":-1, "reason":""}

static func update(world: RefCounted) -> void:
	if world.objective.is_empty() or world.objective.status != "pending": return
	var item = definition(world.objective.id)
	world.objective.progress = count(world, item)
	if world.objective.progress >= item.regions:
		world.objective.status = "completed"
	elif world.day >= item.deadline or not world.outcome.is_empty():
		world.objective.status = "failed"
		world.objective.reason = "deadline" if world.day >= item.deadline else "game_over"
	else: return
	world.objective.resolved_day = world.day
	world.journal.append("Jour %d · %s" % [world.day, summary(world)])

static func description(item: Dictionary) -> String:
	return "%s : %d régions à %d %% touchés avant la fin du jour %d. Aucun bonus de points ou de score." % [item.name, item.regions, item.coverage_percent, item.deadline]

static func summary(world: RefCounted) -> String:
	if world.objective.is_empty(): return "Objectif facultatif : aucun."
	var item = definition(world.objective.id)
	var state = "En cours · échéance J%d inclus" % item.deadline
	if world.objective.status == "completed": state = "Réussi au jour %d" % world.objective.resolved_day
	elif world.objective.status == "failed": state = "Non atteint · " + ("échéance J%d" % item.deadline if world.objective.reason == "deadline" else "fin de partie J%d" % world.objective.resolved_day)
	return "%s · %d/%d régions à %d %% · %s" % [item.name, world.objective.progress, item.regions, item.coverage_percent, state]

static func valid_state(state: Variant, world: RefCounted) -> bool:
	if not state is Dictionary: return false
	if state.is_empty(): return true
	if state.size() != 5 or not state.get("id") is String: return false
	for key in ["id", "status", "progress", "resolved_day", "reason"]:
		if not state.has(key): return false
	var item = definition(state.id)
	if item.is_empty() or item.scenario != world.scenario.id: return false
	if not integer(state.get("progress"), 0, int(item.regions)) or not integer(state.get("resolved_day"), -1, world.day): return false
	var current = count(world, item)
	match state.get("status"):
		"pending": return state.reason == "" and state.resolved_day == -1 and state.progress == current and current < item.regions and world.day < item.deadline and world.outcome.is_empty()
		"completed": return state.reason == "" and state.progress == item.regions and current >= item.regions and state.resolved_day >= 1 and state.resolved_day <= item.deadline
		"failed":
			if state.progress >= item.regions or state.progress > current: return false
			if state.get("reason") == "deadline": return state.resolved_day == item.deadline and world.day >= item.deadline
			return state.get("reason") == "game_over" and not world.outcome.is_empty() and state.resolved_day == world.day and world.day < item.deadline and state.progress == current
	return false

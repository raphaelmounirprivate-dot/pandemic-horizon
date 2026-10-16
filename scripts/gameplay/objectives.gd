extends RefCounted
## Optional observation only: never modifies population, points, score or RNG.
const PATH = "res://data/objectives.json"
static var _catalog: Variant = null

static func catalog() -> Variant:
	if _catalog == null: _catalog = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return _catalog.duplicate(true) if _catalog is Dictionary else _catalog

static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= low and value <= high

static func validate(data: Variant) -> String:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("objectives") is Array: return "Catalogue d'objectifs invalide."
	var ids: Array = []
	for item in data.objectives:
		if not item is Dictionary: return "Objectif invalide."
		if not item.get("id") is String or item.id.is_empty() or item.id in ids: return "Identifiant d'objectif invalide."
		if not item.get("name") is String or item.name.is_empty() or item.name.length() > 80: return "Nom d'objectif invalide."
		if not integer(item.get("deadline"), 1, 500): return "Échéance d'objectif invalide."
		match item.get("kind"):
			"coverage":
				if item.get("scenario") != "standard": return "Scénario d'objectif invalide."
				if not integer(item.get("regions"), 1, 24) or not integer(item.get("coverage_percent"), 1, 100): return "Seuil d'objectif invalide."
			"seasonal_flow":
				if item.get("scenario") != "degel2042" or not item.get("source") is String or not item.get("phase") is String: return "Référence d'objectif invalide."
				if not integer(item.get("quota"), 1, 100000) or not item.get("routes") is Array or item.routes.size() != 2: return "Routes d'objectif invalides."
				var targets: Array = []
				for route in item.routes:
					if not route is Dictionary or not route.get("target") is String or route.target.is_empty() or route.target == item.source or route.target in targets or not integer(route.get("start_day"), 1, int(item.deadline)): return "Fenêtre d'objectif invalide."
					targets.append(route.target)
			_: return "Type d'objectif invalide."
		ids.append(item.id)
	return ""

static func validate_context(item: Dictionary, scenario: Dictionary, events: Array) -> String:
	if item.scenario != scenario.id: return "Objectif incompatible avec le scénario."
	if item.kind != "seasonal_flow": return ""
	var begin = -1
	var end = 501
	for phase in scenario.phases:
		if phase.id == item.phase: begin = int(phase.start_day)
		elif begin >= 0 and phase.start_day > begin: end = mini(end, int(phase.start_day))
	if begin < 0 or item.deadline >= end: return "Phase d'objectif invalide."
	for requested in item.routes:
		var found = false
		var edge = [item.source,requested.target]
		var required_day = begin
		for route in scenario.seasonal_routes:
			if (route.edge == edge or route.edge == [requested.target,item.source]) and requested.start_day >= route.open_day: found = true
		for event in events:
			if event.kind == "route_closure" and (event.target == edge or event.target == [requested.target,item.source]) and event.start_day >= begin and event.start_day <= item.deadline:
				required_day = maxi(required_day,int(event.start_day + event.duration))
		if not found or requested.start_day < required_day: return "Objectif avant la réouverture d'une route."
	return ""

static func for_scenario(scenario_id: String) -> Dictionary:
	var data = catalog()
	if not validate(data).is_empty(): return {}
	for item in data.objectives:
		if item.scenario == scenario_id: return item
	return {}

static func definition(id: String) -> Dictionary:
	var data = catalog()
	if not validate(data).is_empty(): return {}
	for item in data.objectives:
		if item.id == id: return item
	return {}

static func count(world: RefCounted, item: Dictionary) -> int:
	if item.kind == "seasonal_flow": return route_progress(world.objective, item)
	var total = 0
	for region in world.regions:
		if (region.active + region.removed) * 100 >= region.population * item.coverage_percent: total += 1
	return mini(total, int(item.regions))

static func initial(id: String) -> Dictionary:
	if id.is_empty(): return {}
	var state = {"id":id, "status":"pending", "progress":0, "resolved_day":-1, "reason":""}
	var item = definition(id)
	if item.kind == "seasonal_flow":
		state.routes = {}
		for route in item.routes: state.routes[route.target] = 0
	return state

static func route_progress(state: Dictionary, item: Dictionary) -> int:
	var total = 0
	for route in item.routes:
		if state.routes[route.target] >= item.quota: total += 1
	return total

static func record_exchange(world: RefCounted, source: String, target: String, units: int) -> void:
	if not world.objective.has("routes") or world.objective.status != "pending" or units <= 0: return
	var item = definition(world.objective.id)
	if item.kind != "seasonal_flow" or source != item.source or world.phase.id != item.phase or world.day > item.deadline or not world.route_is_open([source,target]): return
	for route in item.routes:
		if route.target == target and world.day >= route.start_day:
			world.objective.routes[target] = mini(int(item.quota),world.objective.routes[target] + units)

static func update(world: RefCounted) -> void:
	if world.objective.is_empty() or world.objective.status != "pending": return
	var item = definition(world.objective.id)
	world.objective.progress = count(world, item)
	var required = int(item.regions) if item.kind == "coverage" else item.routes.size()
	if world.objective.progress >= required:
		world.objective.status = "completed"
	elif world.day >= item.deadline or not world.outcome.is_empty():
		world.objective.status = "failed"
		world.objective.reason = "deadline" if world.day >= item.deadline else "game_over"
	else: return
	world.objective.resolved_day = world.day
	world.journal.append("Jour %d · %s" % [world.day, summary(world)])

static func description(item: Dictionary) -> String:
	if item.is_empty(): return "Objectif facultatif indisponible."
	if item.kind == "seasonal_flow":
		var windows: Array[String] = []
		for route in item.routes: windows.append("%s (J%d–%d)" % [route.target.capitalize(),route.start_day,item.deadline])
		return "%d unités d'échange depuis Boréale vers %s, par route. Aucun bonus de points ou de score." % [item.quota," et ".join(windows)]
	return "%s : %d régions à %d %% touchés avant la fin du jour %d. Aucun bonus de points ou de score." % [item.name, item.regions, item.coverage_percent, item.deadline]

static func summary(world: RefCounted) -> String:
	if world.objective.is_empty(): return "Objectif facultatif : aucun."
	var item = definition(world.objective.id)
	var state = "En cours · échéance J%d inclus" % item.deadline
	if world.objective.status == "completed": state = "Réussi au jour %d" % world.objective.resolved_day
	elif world.objective.status == "failed": state = "Non atteint · " + ("échéance J%d" % item.deadline if world.objective.reason == "deadline" else "fin de partie J%d" % world.objective.resolved_day)
	if item.kind == "seasonal_flow": return "%s · Orient %d/%d · Centrale %d/%d unités · %s" % [item.name,world.objective.routes.orient,item.quota,world.objective.routes.centrale,item.quota,state]
	return "%s · %d/%d régions à %d %% · %s" % [item.name, world.objective.progress, item.regions, item.coverage_percent, state]

static func valid_state(state: Variant, world: RefCounted) -> bool:
	if not state is Dictionary: return false
	if state.is_empty(): return true
	if not state.get("id") is String: return false
	for key in ["id", "status", "progress", "resolved_day", "reason"]:
		if not state.has(key): return false
	var item = definition(state.id)
	if item.is_empty() or item.scenario != world.scenario.id: return false
	if not validate_context(item,world.scenario,world.event_definitions).is_empty(): return false
	var required = int(item.regions) if item.kind == "coverage" else item.routes.size()
	var current = count(world, item) if item.kind == "coverage" else 0
	var earliest = 1
	if item.kind == "seasonal_flow":
		if state.size() != 6 or not state.get("routes") is Dictionary or state.routes.size() != item.routes.size(): return false
		for route in item.routes:
			if not integer(state.routes.get(route.target),0,int(item.quota)): return false
			if world.day < route.start_day and state.routes[route.target] != 0: return false
			earliest = maxi(earliest,int(route.start_day))
		current = route_progress(state,item)
	else:
		if state.size() != 5: return false
	if not integer(state.get("progress"), 0, required) or not integer(state.get("resolved_day"), -1, world.day): return false
	if item.kind == "seasonal_flow" and state.progress != current: return false
	match state.get("status"):
		"pending": return state.reason == "" and state.resolved_day == -1 and state.progress == current and current < required and world.day < item.deadline and world.outcome.is_empty()
		"completed": return state.reason == "" and state.progress == required and current >= required and state.resolved_day >= earliest and state.resolved_day <= item.deadline
		"failed":
			if state.progress >= required or state.progress > current: return false
			if state.get("reason") == "deadline": return state.resolved_day == item.deadline and world.day >= item.deadline
			return state.get("reason") == "game_over" and not world.outcome.is_empty() and state.resolved_day == world.day and world.day < item.deadline and state.progress == current
	return false

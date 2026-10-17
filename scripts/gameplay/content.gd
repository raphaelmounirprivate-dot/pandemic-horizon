extends RefCounted
## Validate authored content before it can mutate a running world.

static func load_files() -> Dictionary:
	return {
		"evolutions": JSON.parse_string(FileAccess.get_file_as_string("res://data/evolutions.json")),
		"events": JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))
	}

static func number(value: Variant, minimum: float, maximum: float, integer: bool = false) -> bool:
	if not (value is float or value is int):
		return false
	return is_finite(float(value)) and value >= minimum and value <= maximum and (not integer or value == floor(value))

static func text(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()

static func validate(source: Variant, regions: Array, connections: Array) -> String:
	if not source is Dictionary:
		return "Contenu de jeu absent ou invalide."
	var upgrades = source.get("evolutions")
	if not upgrades is Dictionary or upgrades.get("schema_version") != 1 or not upgrades.get("evolutions") is Array:
		return "Version ou liste des évolutions invalide."
	if upgrades.evolutions.is_empty():
		return "Aucune évolution définie."
	var ids: Array = []
	var definitions: Dictionary = {}
	for item in upgrades.evolutions:
		if not item is Dictionary or not text(item.get("id")):
			return "Identifiant d'évolution invalide."
		if item.id in ids or not text(item.get("name")) or not text(item.get("effect")):
			return "Évolution dupliquée ou description absente."
		if not number(item.get("cost"), 0, 100000, true) or not item.get("requires") is Array:
			return "Coût ou prérequis invalide : " + item.id
		if not item.get("modifiers") is Dictionary or item.modifiers.is_empty():
			return "Effets absents : " + item.id
		for modifier in item.modifiers:
			if modifier not in ["growth_bonus", "exchange_multiplier", "cure_multiplier", "cold_multiplier", "seasonal_multiplier", "climate_penalty_multiplier", "land_multiplier", "air_multiplier", "sea_multiplier", "incident_transport_penalty", "incident_research_penalty", "incident_growth_penalty"]:
				return "Effet d'évolution inconnu : " + str(modifier)
			var minimum = 0.0 if modifier == "growth_bonus" else 0.05
			var maximum = 1.0 if modifier == "climate_penalty_multiplier" or modifier.begins_with("incident_") else 5.0
			if not number(item.modifiers[modifier], minimum, maximum):
				return "Coefficient d'évolution hors limites."
		ids.append(item.id)
		definitions[item.id] = item
	for item in upgrades.evolutions:
		var unique: Array = []
		for prerequisite in item.requires:
			if not prerequisite is String or prerequisite not in ids or prerequisite == item.id or prerequisite in unique:
				return "Prérequis inconnu, dupliqué ou circulaire : " + item.id
			unique.append(prerequisite)
	# Resolve the prerequisite DAG; reject cycles of any length.
	var resolved: Array = []
	for iteration in range(ids.size()):
		for id in ids:
			if id in resolved:
				continue
			var ready = true
			for prerequisite in definitions[id].requires:
				ready = ready and prerequisite in resolved
			if ready:
				resolved.append(id)
	if resolved.size() != ids.size():
		return "Cycle dans les prérequis d'évolution."
	for item in upgrades.evolutions:
		var excluded = item.get("excludes", [])
		if not excluded is Array: return "Exclusions d'évolution invalides."
		var seen: Array = []
		for id in excluded:
			if not id is String or id not in ids or id == item.id or id in seen: return "Exclusion inconnue, dupliquée ou vers soi-même."
			if not definitions[id].get("excludes", []) is Array or item.id not in definitions[id].get("excludes", []): return "Les exclusions doivent être réciproques."
			seen.append(id)
		var ancestors: Array = item.requires.duplicate()
		var visited: Array = []
		while not ancestors.is_empty():
			var required = ancestors.pop_back()
			if required in visited: continue
			visited.append(required)
			if required in excluded: return "Une évolution ne peut exclure un de ses prérequis."
			ancestors.append_array(definitions[required].requires)
	var events = source.get("events")
	if not events is Dictionary or events.get("schema_version") != 1 or not events.get("events") is Array:
		return "Version ou liste des événements invalide."
	var detection = events.get("detection")
	if not detection is Dictionary:
		return "Règles de détection absentes."
	if not number(detection.get("active_ratio"), 0.001, 1.0) or not number(detection.get("min_active"), 1, 1000000000, true):
		return "Seuil de détection invalide."
	if not number(detection.get("reaction_duration"), 1, 365, true) or not number(detection.get("reaction_factor"), 0.05, 1.0):
		return "Réaction régionale invalide."
	var cure = events.get("cure")
	if not cure is Dictionary:
		return "Règles du remède absentes."
	for key in ["base_gain", "coverage_gain", "per_detected_gain"]:
		if not number(cure.get(key), 0, 10):
			return "Coefficient du remède invalide."
	var region_ids: Array = []
	for region in regions:
		region_ids.append(region.id)
	ids.clear()
	for item in events.events:
		if not item is Dictionary or not text(item.get("id")) or not text(item.get("name")):
			return "Identifiant ou nom d'événement absent."
		if item.id in ids or item.id.begins_with("reaction_"):
			return "Identifiant d'événement dupliqué ou réservé."
		ids.append(item.id)
		if not number(item.get("duration"), 1, 365, true) or not number(item.get("start_day"), 1, 10000, true):
			return "Jour ou durée d'événement invalide."
		if not number(item.get("factor"), 0.05, 5.0):
			return "Coefficient d'événement invalide."
		match item.get("kind"):
			"route_closure":
				var target = item.get("target")
				if not target is Array or target.size() != 2:
					return "Route d'événement invalide."
				if target not in connections and [target[1], target[0]] not in connections:
					return "Route d'événement inconnue."
				if item.factor != 1.0:
					return "Une fermeture de route ne prend pas de coefficient."
			"growth_multiplier":
				if not item.get("target") is String or item.target not in region_ids:
					return "Région d'événement inconnue."
			"cure_multiplier":
				if item.get("target") != "global":
					return "Le remède est un effet mondial."
			"transport_multiplier":
				if item.get("target") not in ["land", "air", "sea"]:
					return "Type de transport d'événement inconnu."
			_:
				return "Type d'événement inconnu."
	return ""

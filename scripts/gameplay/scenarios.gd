extends RefCounted

const Content = preload("res://scripts/gameplay/content.gd")

static func load_catalog() -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/scenarios.json"))

static func connections_for(data: Dictionary, scenario: Dictionary) -> Array:
	var connections = data.connections.duplicate(true)
	for route in scenario.seasonal_routes:
		if route.edge not in connections and [route.edge[1], route.edge[0]] not in connections:
			connections.append(route.edge.duplicate())
	return connections

static func gameplay_for(base: Dictionary, scenario: Dictionary) -> Dictionary:
	var gameplay = base.duplicate(true)
	gameplay.evolutions.evolutions.append_array(scenario.extra_evolutions.duplicate(true))
	if scenario.has("events_override"):
		gameplay.events.events = scenario.events_override.duplicate(true)
	return gameplay

static func validate(catalog: Variant, data: Dictionary, base: Dictionary) -> String:
	if not catalog is Dictionary or catalog.get("schema_version") != 1:
		return "Catalogue des scénarios invalide."
	if not catalog.get("difficulties") is Array or catalog.difficulties.is_empty() or not catalog.get("scenarios") is Array or catalog.scenarios.is_empty():
		return "Scénarios ou difficultés absents."
	var base_error = Content.validate(base, data.regions, data.connections)
	if not base_error.is_empty():
		return base_error
	var ids: Array = []
	for difficulty in catalog.difficulties:
		if not difficulty is Dictionary or not Content.text(difficulty.get("id")) or not Content.text(difficulty.get("name")):
			return "Difficulté invalide."
		if difficulty.id in ids:
			return "Difficulté dupliquée."
		ids.append(difficulty.id)
		for key in ["cure_multiplier", "detection_multiplier", "score_multiplier"]:
			if not Content.number(difficulty.get(key), 0.1, 5):
				return "Coefficient de difficulté invalide."
	ids.clear()
	var regions: Array = []
	for region in data.regions: regions.append(region.id)
	for scenario in catalog.scenarios:
		if not scenario is Dictionary or not Content.text(scenario.get("id")) or not Content.text(scenario.get("name")) or not Content.text(scenario.get("description")):
			return "Scénario invalide."
		if scenario.id in ids:
			return "Scénario dupliqué."
		ids.append(scenario.id)
		if not scenario.get("forced_start") is String or (scenario.forced_start != "" and scenario.forced_start not in regions):
			return "Départ imposé inconnu."
		if not scenario.get("cold_regions") is Array or not scenario.get("seasonal_routes") is Array or not scenario.get("extra_evolutions") is Array:
			return "Régions froides, routes ou évolutions du scénario invalides."
		var cold: Array = []
		for region in scenario.cold_regions:
			if region not in regions or region in cold:
				return "Région froide inconnue ou dupliquée."
			cold.append(region)
		var routes: Array = []
		for route in scenario.seasonal_routes:
			if not route is Dictionary or not route.get("edge") is Array or route.edge.size() != 2:
				return "Route saisonnière invalide."
			if route.edge[0] not in regions or route.edge[1] not in regions or route.edge[0] == route.edge[1] or not Content.number(route.get("open_day"), 1, 10000, true):
				return "Référence ou date de route saisonnière invalide."
			var pair = route.edge.duplicate()
			pair.sort()
			if pair in routes:
				return "Route saisonnière dupliquée."
			routes.append(pair)
		if not scenario.get("phases") is Array or scenario.phases.is_empty():
			return "Phases absentes."
		var last_day = -1
		var phases: Array = []
		for phase in scenario.phases:
			if not phase is Dictionary or not Content.text(phase.get("id")) or not Content.text(phase.get("name")):
				return "Phase invalide."
			if phase.id in phases or not Content.number(phase.get("start_day"), 0, 10000, true) or phase.start_day <= last_day:
				return "Phases dupliquées ou hors ordre."
			if last_day == -1 and phase.start_day != 0:
				return "La première phase doit commencer au jour zéro."
			phases.append(phase.id)
			last_day = int(phase.start_day)
			if not Content.number(phase.get("temperature"), -60, 60):
				return "Température de jeu invalide."
			for key in ["cold_factor", "warm_factor", "cure_multiplier"]:
				if not Content.number(phase.get(key), 0.05, 5):
					return "Coefficient de phase invalide."
		if scenario.has("events_override") and not scenario.events_override is Array:
			return "Événements de scénario invalides."
		var error = Content.validate(gameplay_for(base, scenario), data.regions, connections_for(data, scenario))
		if not error.is_empty():
			return scenario.name + " : " + error
	return ""

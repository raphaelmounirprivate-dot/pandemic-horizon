extends RefCounted
const MODES = ["land", "air", "sea"]
const NAMES = {"land": "Terrestre", "air": "Aérien", "sea": "Maritime"}
const Content = preload("res://scripts/gameplay/content.gd")

static func load_file() -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string("res://data/transports.json"))

static func key(edge: Array) -> String:
	var pair = edge.duplicate()
	pair.sort()
	return "|".join(pair)

static func all_edges(data: Dictionary, catalog: Dictionary) -> Array:
	var edges = data.connections.duplicate(true)
	for scenario in catalog.scenarios:
		for route in scenario.seasonal_routes:
			if not edges.any(func(edge): return key(edge) == key(route.edge)): edges.append(route.edge.duplicate())
	return edges

static func neutral(data: Dictionary, catalog: Dictionary) -> Dictionary:
	# Explicit custom-world callers retain unit exchange coefficients unless supplied.
	var result = {"schema_version": 1, "profiles": {"land": 1.0, "air": 1.0, "sea": 1.0}, "routes": []}
	for edge in all_edges(data, catalog):
		var mode = "land"
		for scenario in catalog.scenarios:
			if scenario.seasonal_routes.any(func(route): return key(route.edge) == key(edge)): mode = "sea"
		result.routes.append({"edge": edge.duplicate(), "mode": mode})
	return result

static func validate(source: Variant, data: Dictionary, catalog: Dictionary) -> String:
	if not source is Dictionary or source.get("schema_version") != 1: return "Version des transports invalide."
	if not source.get("profiles") is Dictionary or source.profiles.size() != 3: return "Trois profils de transport sont requis."
	for mode in MODES:
		if not Content.number(source.profiles.get(mode), 0.05, 5): return "Coefficient de transport invalide."
	if not source.get("routes") is Array: return "Types de liaison absents."
	var expected: Array = []
	for edge in all_edges(data, catalog): expected.append(key(edge))
	var found: Array = []
	for route in source.routes:
		if not route is Dictionary or not route.get("edge") is Array or route.edge.size() != 2: return "Liaison de transport invalide."
		if not route.edge[0] is String or not route.edge[1] is String: return "Extrémité de transport invalide."
		var id = key(route.edge)
		if id not in expected or id in found or route.get("mode") not in MODES: return "Liaison inconnue, dupliquée ou type invalide."
		for scenario in catalog.scenarios:
			if scenario.seasonal_routes.any(func(item): return key(item.edge) == id) and route.mode != "sea": return "Une route saisonnière arctique doit être maritime."
		found.append(id)
	return "" if found.size() == expected.size() else "Chaque liaison doit avoir un type de transport."

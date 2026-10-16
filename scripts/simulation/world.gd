class_name PandemicWorld
extends RefCounted
## Abstract game model. No real biological parameters. One step = one day.

const DATA_PATH = "res://data/regions.json"
const Content = preload("res://scripts/gameplay/content.gd")
const Scenarios = preload("res://scripts/gameplay/scenarios.gd")
const Transports = preload("res://scripts/gameplay/transports.gd")
const SPECIALIZATIONS = ["land_network", "air_bridge", "sea_logistics"]
const Objectives = preload("res://scripts/gameplay/objectives.gd")
var objective: Dictionary = {}

var regions: Array = []
var connections: Array = []
var day: int = 0
var points: int = 8
var cure: float = 0.0
var outcome: String = ""
var purchased: Array[String] = []
var journal: Array[String] = []
var rng = RandomNumberGenerator.new()
var evolutions: Dictionary = {}
var event_definitions: Array = []
var detection_rules: Dictionary = {}
var cure_rules: Dictionary = {}
var active_events: Array = []
var activated_events: Array[String] = []
var scenario: Dictionary = {}
var difficulty: Dictionary = {}
var phase: Dictionary = {}
var start_region_id: String = ""
var transport_profiles: Dictionary = {}
var transport_modes: Dictionary = {}

static func validate_data(data: Variant) -> String:
	if not data is Dictionary:
		return "Le contenu doit être un objet JSON."
	if data.get("schema_version") != 1:
		return "Version des données inconnue."
	if not data.get("regions") is Array or data.regions.is_empty():
		return "Les régions sont absentes."
	var ids: Array = []
	var positions: Array = []
	for region in data.regions:
		if not region is Dictionary:
			return "Région invalide."
		if not region.get("id") is String or region.id.is_empty() or region.id in ids:
			return "Identifiant de région absent ou dupliqué."
		if not region.get("name") is String or region.name.is_empty():
			return "Nom de région absent."
		var population = region.get("population")
		if not (population is int or population is float):
			return "Population invalide."
		if not is_finite(float(population)) or population < 200 or population > 1000000000 or population != floor(population):
			return "Population hors limites."
		var position = region.get("position")
		if not position is Array or position.size() != 2:
			return "Position de région invalide."
		for coordinate in position:
			if not (coordinate is float or coordinate is int):
				return "Coordonnée invalide."
			if not is_finite(float(coordinate)) or coordinate < 0.0 or coordinate > 1.0:
				return "Coordonnée hors carte."
		if position in positions:
			return "Deux régions partagent la même position."
		positions.append(position)
		ids.append(region.id)
	if not data.get("connections") is Array:
		return "Connexions absentes."
	var edges: Array = []
	for edge in data.connections:
		if not edge is Array or edge.size() != 2:
			return "Connexion invalide."
		if edge[0] not in ids or edge[1] not in ids or edge[0] == edge[1]:
			return "Connexion vers une région inconnue ou vers elle-même."
		var pair = [edge[0], edge[1]]
		pair.sort()
		if pair in edges:
			return "Connexion dupliquée."
		edges.append(pair)
	return ""

func start(start_id: String, seed_value: int = 2042, source: Variant = null, gameplay_source: Variant = null, scenario_id: String = "standard", difficulty_id: String = "normal", catalog_source: Variant = null, transport_source: Variant = null, objective_id: String = "") -> String:
	if not objective_id.is_empty():
		var item = Objectives.definition(objective_id)
		if item.is_empty() or item.scenario != scenario_id: return "Objectif facultatif indisponible pour ce scénario."
	var data: Variant = source
	if data == null:
		if not FileAccess.file_exists(DATA_PATH):
			return "Fichier des régions introuvable."
		data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	var error = validate_data(data)
	if not error.is_empty():
		return error
	var selected = false
	for region in data.regions:
		selected = selected or region.id == start_id
	if not selected:
		return "Région de départ inconnue."
	var gameplay: Variant = Content.load_files() if gameplay_source == null else gameplay_source
	error = Content.validate(gameplay, data.regions, data.connections)
	if not error.is_empty():
		return error
	var catalog: Variant = Scenarios.load_catalog() if catalog_source == null else catalog_source
	error = Scenarios.validate(catalog, data, gameplay)
	if not error.is_empty():
		return error
	var chosen_scenario: Dictionary = {}
	var chosen_difficulty: Dictionary = {}
	for item in catalog.scenarios:
		if item.id == scenario_id: chosen_scenario = item
	for item in catalog.difficulties:
		if item.id == difficulty_id: chosen_difficulty = item
	if chosen_scenario.is_empty() or chosen_difficulty.is_empty():
		return "Scénario ou difficulté inconnu."
	if not objective_id.is_empty():
		error = Objectives.validate_context(Objectives.definition(objective_id),chosen_scenario,Scenarios.gameplay_for(gameplay,chosen_scenario).events.events)
		if not error.is_empty(): return error
	if chosen_scenario.forced_start != "" and chosen_scenario.forced_start != start_id:
		return "Ce scénario impose un départ en " + chosen_scenario.forced_start + "."
	var transports: Variant = transport_source
	if transports == null: transports = Transports.load_file() if source == null else Transports.neutral(data, catalog)
	error = Transports.validate(transports, data, catalog)
	if not error.is_empty(): return error
	transport_profiles = transports.profiles.duplicate(true)
	transport_modes.clear()
	for route in transports.routes: transport_modes[Transports.key(route.edge)] = route.mode
	scenario = chosen_scenario.duplicate(true)
	difficulty = chosen_difficulty.duplicate(true)
	phase = scenario.phases[0].duplicate(true)
	gameplay = Scenarios.gameplay_for(gameplay, scenario)
	regions = data.regions.duplicate(true)
	connections = Scenarios.connections_for(data, scenario)
	evolutions.clear()
	for item in gameplay.evolutions.evolutions:
		evolutions[item.id] = item.duplicate(true)
	event_definitions = gameplay.events.events.duplicate(true)
	detection_rules = gameplay.events.detection.duplicate(true)
	cure_rules = gameplay.events.cure.duplicate(true)
	active_events.clear()
	activated_events.clear()
	day = 0
	start_region_id = start_id
	points = 8
	cure = 0.0
	outcome = ""
	purchased.clear()
	journal.clear()
	objective = Objectives.initial(objective_id)
	rng.seed = seed_value
	for region in regions:
		region["active"] = 200 if region.id == start_id else 0
		region["removed"] = 0
		region["healthy"] = int(region.population) - region.active
		region["detected"] = false
	journal.append("Jour 0 · Départ dans la région %s." % region_name(start_id))
	journal.append("Jour 0 · %s · Difficulté %s · Phase %s." % [scenario.name, difficulty.name, phase.name])
	if not objective.is_empty(): journal.append("Jour 0 · Objectif facultatif · " + Objectives.description(Objectives.definition(objective_id)))
	return ""

func region_name(id: String) -> String:
	for region in regions:
		if region.id == id:
			return region.name
	return id

func totals() -> Dictionary:
	var result = {"population": 0, "healthy": 0, "active": 0, "removed": 0, "touched": 0}
	for region in regions:
		for key in ["population", "healthy", "active", "removed"]:
			result[key] += int(region[key])
	result.touched = result.active + result.removed
	return result

func coverage() -> float:
	var total = totals()
	return 0.0 if total.population == 0 else float(total.touched) / total.population

func score() -> int:
	return roundi(maxi(0, roundi(coverage() * 10000.0) - day * 10) * float(difficulty.get("score_multiplier", 1.0)))

func purchase_reason(id: String) -> String:
	if regions.is_empty():
		return "Aucune partie en cours."
	if not outcome.is_empty():
		return "La partie est terminée."
	if not evolutions.has(id):
		return "Évolution inconnue."
	if id in purchased:
		return "Évolution déjà acquise."
	for excluded in evolutions[id].get("excludes", []):
		if excluded in purchased: return "Incompatible : " + evolutions[excluded].name
	for prerequisite in evolutions[id].requires:
		if prerequisite not in purchased:
			return "Prérequis : " + evolutions[prerequisite].name
	if points < evolutions[id].cost:
		return "Points insuffisants."
	return ""

func purchase(id: String) -> String:
	var reason = purchase_reason(id)
	if not reason.is_empty():
		return reason
	points -= int(evolutions[id].cost)
	purchased.append(id)
	journal.append("Jour %d · Évolution acquise : %s." % [day, evolutions[id].name])
	return ""

func upgrade_modifier(key: String, base: float = 1.0) -> float:
	var result = base
	for id in purchased:
		var effects = evolutions[id].modifiers
		if effects.has(key):
			if key == "growth_bonus":
				result += effects[key]
			else:
				result *= effects[key]
	return result

func detected_count() -> int:
	var count = 0
	for region in regions:
		if region.detected:
			count += 1
	return count

func route_is_open(edge: Array) -> bool:
	if edge.size() != 2:
		return false
	if edge not in connections and [edge[1], edge[0]] not in connections:
		return false
	for route in scenario.get("seasonal_routes", []):
		if (route.edge == edge or route.edge == [edge[1], edge[0]]) and day < route.open_day:
			return false
	for effect in active_events:
		if effect.kind == "route_closure" and (effect.target == edge or effect.target == [edge[1], edge[0]]):
			return false
	return true

func route_is_seasonal(edge: Array) -> bool:
	for route in scenario.get("seasonal_routes", []):
		if route.edge == edge or route.edge == [edge[1], edge[0]]:
			return true
	return false

func route_mode(edge: Array) -> String:
	if edge.size() != 2: return ""
	return transport_modes.get(Transports.key(edge), "")

func transport_factor(edge: Array) -> float:
	var mode = route_mode(edge)
	return transport_base_factor(edge) * upgrade_modifier(mode + "_multiplier")

func transport_base_factor(edge: Array) -> float:
	var mode = route_mode(edge)
	if mode.is_empty() or not route_is_open(edge): return 0.0
	return float(transport_profiles[mode]) * event_modifier("transport_multiplier", mode)

func specialization_id() -> String:
	for id in SPECIALIZATIONS:
		if id in purchased: return id
	return ""

func transport_summary(region_id: String) -> String:
	var counts = {"land": [0, 0], "air": [0, 0], "sea": [0, 0]}
	for edge in connections:
		if region_id not in edge: continue
		var mode = route_mode(edge)
		if not counts.has(mode): continue
		counts[mode][1] += 1
		if route_is_open(edge): counts[mode][0] += 1
	return "Liaisons ouvertes : T %d/%d · A %d/%d · M %d/%d" % [counts.land[0], counts.land[1], counts.air[0], counts.air[1], counts.sea[0], counts.sea[1]]

func transport_lines(region_id: String) -> Array[String]:
	var lines: Array[String] = []
	for edge in connections:
		if region_id not in edge: continue
		var other = edge[1] if edge[0] == region_id else edge[0]
		var mode = route_mode(edge)
		lines.append("%s ↔ %s · %s · %s" % [region_name(region_id), region_name(other), Transports.NAMES.get(mode, "Inconnu"), "ouverte ×%.2f" % transport_factor(edge) if route_is_open(edge) else "fermée"])
	return lines

func climate_factor(region_id: String) -> float:
	var cold = region_id in scenario.get("cold_regions", [])
	var factor = float(phase.get("cold_factor" if cold else "warm_factor", 1.0))
	if factor < 1.0:
		factor = 1.0 - (1.0 - factor) * upgrade_modifier("climate_penalty_multiplier")
	if cold:
		factor *= upgrade_modifier("cold_multiplier")
	return factor

func _update_scenario() -> void:
	for candidate in scenario.phases:
		if day == int(candidate.start_day) and candidate.id != phase.id:
			phase = candidate.duplicate(true)
			journal.append("Jour %d · Phase %s · Température fictive %.0f °C · Remède ×%.2f." % [day, phase.name, phase.temperature, phase.cure_multiplier])
	for route in scenario.seasonal_routes:
		if day == int(route.open_day):
			journal.append("Jour %d · Saison ouverte : %s ↔ %s ; les fermetures temporaires restent prioritaires." % [day, region_name(route.edge[0]), region_name(route.edge[1])])

func event_modifier(kind: String, target: String = "global") -> float:
	var factor = 1.0
	for effect in active_events:
		if effect.kind == kind and effect.target == target:
			factor *= effect.factor
	return factor

func effect_description(effect: Dictionary) -> String:
	match effect.kind:
		"route_closure": return "%s ↔ %s : route fermée" % [region_name(effect.target[0]), region_name(effect.target[1])]
		"growth_multiplier": return "%s : croissance ×%.2f" % [region_name(effect.target), effect.factor]
		"cure_multiplier": return "remède ×%.2f" % effect.factor
		"transport_multiplier": return "transport %s : échanges ×%.2f" % [Transports.NAMES[effect.target].to_lower(), effect.factor]
	return ""

func _add_event(definition: Dictionary) -> bool:
	if definition.id in activated_events:
		return false
	var effect = definition.duplicate(true)
	effect["start_day"] = day
	effect["end_day"] = day + int(definition.duration)
	activated_events.append(effect.id)
	active_events.append(effect)
	journal.append("Jour %d · %s — %s ; fin au jour %d." % [day, effect.name, effect_description(effect), effect.end_day])
	return true

func activate_event(id: String) -> String:
	if regions.is_empty() or not outcome.is_empty():
		return "Aucune partie active."
	for definition in event_definitions:
		if definition.id == id:
			return "" if _add_event(definition) else "Événement déjà déclenché."
	return "Événement inconnu."

func _update_events_and_detection() -> void:
	# End is exclusive: duration 8 at day 18 affects days 18 through 25.
	var closed_before: Array = []
	for edge in connections:
		if not route_is_open(edge):
			closed_before.append(edge)
	for i in range(active_events.size() - 1, -1, -1):
		var effect = active_events[i]
		if day >= effect.end_day:
			active_events.remove_at(i)
			journal.append("Jour %d · Fin : %s." % [day, effect.name])
	for definition in event_definitions:
		if day == int(definition.start_day):
			_add_event(definition)
	for region in regions:
		if not region.detected and region.active >= detection_rules.min_active and float(region.active) / region.population >= detection_rules.active_ratio * difficulty.detection_multiplier:
			region.detected = true
			journal.append("Jour %d · Détection dans la région %s ; recherche mondiale renforcée." % [day, region.name])
			_add_event({"id": "reaction_" + region.id, "name": "Réaction de " + region.name, "kind": "growth_multiplier", "target": region.id, "factor": detection_rules.reaction_factor, "duration": detection_rules.reaction_duration})
	# Announce final daily route state, after all expirations AND activations.
	for edge in closed_before:
		if route_is_open(edge):
			journal.append("Jour %d · Route rétablie : %s ↔ %s." % [day, region_name(edge[0]), region_name(edge[1])])

func active_event_lines() -> Array[String]:
	var lines: Array[String] = []
	for effect in active_events:
		lines.append("%s · %s · %d j restants" % [effect.name, effect_description(effect), effect.end_day - day])
	return lines

func step() -> void:
	if not outcome.is_empty() or regions.is_empty():
		return
	day += 1
	_update_scenario()
	_update_events_and_detection()
	var incoming: Dictionary = {}
	var snapshot = regions.duplicate(true)
	var by_id: Dictionary = {}
	for region in snapshot:
		incoming[region.id] = 0
		by_id[region.id] = region
	# Every connection reads the same snapshot. Traversal order cannot cascade.
	for edge in connections:
		if not route_is_open(edge):
			continue
		for direction in [[edge[0], edge[1]], [edge[1], edge[0]]]:
			var source = by_id[direction[0]]
			if source.active >= 1000:
				var seasonal = upgrade_modifier("seasonal_multiplier") if route_is_seasonal(edge) else 1.0
				# Preserve the 0.7 operation order; apply the new specialization last.
				var units = maxi(1, int(source.active * 0.001 * upgrade_modifier("exchange_multiplier") * seasonal * transport_base_factor(edge) * upgrade_modifier(route_mode(edge) + "_multiplier")))
				incoming[direction[1]] += units
				Objectives.record_exchange(self,direction[0],direction[1],units)
	for index in range(regions.size()):
		var before = snapshot[index]
		var region = regions[index]
		var rate = upgrade_modifier("growth_bonus", 0.22) * event_modifier("growth_multiplier", region.id) * climate_factor(region.id)
		var growth = int(before.active * rate * rng.randf_range(0.92, 1.08))
		var new_cases = mini(int(before.healthy), growth + int(incoming[region.id]))
		var recovered = mini(int(before.active), maxi(1, int(before.active * 0.025))) if before.active > 0 else 0
		region.healthy -= new_cases
		region.active += new_cases - recovered
		region.removed += recovered
		if before.active == 0 and new_cases > 0:
			journal.append("Jour %d · Premiers cas dans la région %s." % [day, region.name])
	if detected_count() > 0:
		var gain = cure_rules.base_gain + coverage() * cure_rules.coverage_gain + detected_count() * cure_rules.per_detected_gain
		cure = minf(100.0, cure + gain * upgrade_modifier("cure_multiplier") * event_modifier("cure_multiplier") * difficulty.cure_multiplier * phase.cure_multiplier)
	if day % 5 == 0:
		points += 3
	resolve_outcome()
	Objectives.update(self)

func resolve_outcome() -> void:
	if cure >= 100.0:
		outcome = "defeat_cure"
	elif coverage() >= 0.9:
		outcome = "victory"
	elif totals().active == 0:
		outcome = "defeat_extinction"
	if not outcome.is_empty():
		journal.append("Jour %d · %s" % [day, outcome_text()])

func outcome_text() -> String:
	match outcome:
		"victory": return "Objectif atteint : 90 % de la population a été touchée."
		"defeat_cure": return "Défaite : le remède a été achevé avant l'objectif."
		"defeat_extinction": return "Défaite : aucun cas actif ne subsiste avant l'objectif."
	return "Partie en cours."

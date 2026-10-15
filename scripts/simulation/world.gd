class_name PandemicWorld
extends RefCounted
## Abstract game model. No real biological parameters. One step = one day.

const DATA_PATH = "res://data/regions.json"
const EVOLUTIONS = {
	"transmission": {"name": "Diffusion", "cost": 12, "effect": "Progression locale : +8 points de pourcentage."},
	"mobility": {"name": "Mobilité", "cost": 10, "effect": "Échanges entre régions : multipliés par 3."},
	"discretion": {"name": "Discrétion", "cost": 14, "effect": "Progression du remède : réduite de 30 %."}
}

var regions: Array = []
var connections: Array = []
var day: int = 0
var points: int = 8
var cure: float = 0.0
var outcome: String = ""
var purchased: Array[String] = []
var journal: Array[String] = []
var rng = RandomNumberGenerator.new()

static func validate_data(data: Variant) -> String:
	if not data is Dictionary:
		return "Le contenu doit être un objet JSON."
	if data.get("schema_version") != 1:
		return "Version des données inconnue."
	if not data.get("regions") is Array or data.regions.is_empty():
		return "Les régions sont absentes."
	var ids: Array = []
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

func start(start_id: String, seed_value: int = 2042, source: Variant = null) -> String:
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
	regions = data.regions.duplicate(true)
	connections = data.connections.duplicate(true)
	day = 0
	points = 8
	cure = 0.0
	outcome = ""
	purchased.clear()
	journal.clear()
	rng.seed = seed_value
	for region in regions:
		region["active"] = 200 if region.id == start_id else 0
		region["removed"] = 0
		region["healthy"] = int(region.population) - region.active
	journal.append("Jour 0 · Départ dans la région %s." % region_name(start_id))
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
	return maxi(0, roundi(coverage() * 10000.0) - day * 10)

func purchase(id: String) -> String:
	if not outcome.is_empty():
		return "La partie est terminée."
	if not EVOLUTIONS.has(id):
		return "Évolution inconnue."
	if id in purchased:
		return "Évolution déjà acquise."
	if points < EVOLUTIONS[id].cost:
		return "Points insuffisants."
	points -= EVOLUTIONS[id].cost
	purchased.append(id)
	journal.append("Jour %d · Évolution acquise : %s." % [day, EVOLUTIONS[id].name])
	return ""

func step() -> void:
	if not outcome.is_empty() or regions.is_empty():
		return
	day += 1
	var incoming: Dictionary = {}
	var snapshot = regions.duplicate(true)
	var by_id: Dictionary = {}
	for region in snapshot:
		incoming[region.id] = 0
		by_id[region.id] = region
	# Every connection reads the same snapshot. Traversal order cannot cascade.
	for edge in connections:
		for direction in [[edge[0], edge[1]], [edge[1], edge[0]]]:
			var source = by_id[direction[0]]
			if source.active >= 1000:
				incoming[direction[1]] += maxi(1, int(source.active * (0.003 if "mobility" in purchased else 0.001)))
	for index in range(regions.size()):
		var before = snapshot[index]
		var region = regions[index]
		var rate = 0.22 + (0.08 if "transmission" in purchased else 0.0)
		var growth = int(before.active * rate * rng.randf_range(0.92, 1.08))
		var new_cases = mini(int(before.healthy), growth + int(incoming[region.id]))
		var recovered = mini(int(before.active), maxi(1, int(before.active * 0.025))) if before.active > 0 else 0
		region.healthy -= new_cases
		region.active += new_cases - recovered
		region.removed += recovered
		if before.active == 0 and new_cases > 0:
			journal.append("Jour %d · Premiers cas dans la région %s." % [day, region.name])
	if day > 25:
		cure = minf(100.0, cure + (1.6 + coverage() * 0.8) * (0.7 if "discretion" in purchased else 1.0))
	if day % 5 == 0:
		points += 3
	resolve_outcome()

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

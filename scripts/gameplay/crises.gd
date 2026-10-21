extends RefCounted
const PATH = "res://data/crises.json"
const PROFILE = "crises-0.20"
const Content = preload("res://scripts/gameplay/content.gd")
const Transports = preload("res://scripts/gameplay/transports.gd")
static func load_file() -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))
static func catalog(base: Variant, source: Variant = null) -> Variant:
	var data: Variant = load_file() if source == null else source
	if not base is Dictionary or not data is Dictionary or not data.get("scenario") is Dictionary: return {}
	var result: Variant = base.duplicate(true)
	result.scenarios.append(data.scenario.duplicate(true))
	return result
static func build(base: Dictionary, regions: Array, connections: Array, transports: Dictionary, seed_value: int, scenario_id: String, source: Variant = null) -> Dictionary:
	var data: Variant = load_file() if source == null else source
	if not data is Dictionary or data.get("schema_version") != 1 or data.get("profile") != PROFILE: return {"error":"Profil des aléas invalide."}
	if not data.get("evolutions") is Array or data.evolutions.size() != 3 or not data.get("templates") is Array or data.templates.size() != 8: return {"error":"Catalogue des aléas incomplet."}
	var content: Dictionary = base.duplicate(true)
	for item: Variant in data.evolutions:
		if not item is Dictionary or not item.get("short") is String or item.short.is_empty() or item.short.length() > 8: return {"error":"Libellé de compétence invalide."}
	content.evolutions.evolutions.append_array(data.evolutions.duplicate(true))
	var ids: Array = []
	for item: Variant in data.templates:
		if not item is Dictionary or not Content.text(item.get("id")) or item.id in ids or not Content.text(item.get("name")): return {"error":"Type d'aléa invalide."}
		ids.append(item.id)
		if not Content.number(item.get("min_duration"),1,14,true) or not Content.number(item.get("max_duration"),item.min_duration,14,true) or not Content.number(item.get("factor"),0.25,2): return {"error":"Durée ou coefficient d'aléa invalide."}
		if item.get("impact") not in ["favorable","défavorable"]: return {"error":"Conséquence d'aléa invalide."}
		var valid: bool = (item.get("kind") == "route_closure" and item.get("target") == "sea_route" and item.factor == 1) or (item.get("kind") == "growth_multiplier" and item.get("target") == "region") or (item.get("kind") == "cure_multiplier" and item.get("target") == "global") or (item.get("kind") == "transport_multiplier" and item.get("target") in ["land","air","sea"])
		if not valid: return {"error":"Effet d'aléa inconnu."}
	var sea_routes: Array = []
	for route: Variant in transports.routes:
		if route.mode == "sea": sea_routes.append(route.edge)
	if sea_routes.is_empty(): return {"error":"Les tempêtes exigent une liaison maritime."}
	# Separate stream: opting out consumes no simulation randomness. Seeded draws
	# are reconstructed identically on load; the upcoming calendar is not shown.
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = seed_value ^ 0x20422020
	var bag: Array = []
	for i: int in range(12):
		if bag.is_empty():
			bag = range(data.templates.size())
			for j: int in range(bag.size()-1,0,-1):
				var k: int = random.randi_range(0,j)
				var previous: Variant = bag[j]
				bag[j] = bag[k]
				bag[k] = previous
		var template: Variant = data.templates[bag.pop_back()]
		var event: Dictionary = {"id":"incident_%02d" % i,"name":"Aléa %s · %s" % [template.impact,template.name],"kind":template.kind,"target":template.target,"factor":template.factor,"start_day":(12 if scenario_id == "fragile2042" else 18)+i*(6 if scenario_id == "fragile2042" else 8)+random.randi_range(-2,2),"duration":random.randi_range(int(template.min_duration),int(template.max_duration)),"source":"crisis","template":template.id,"impact":template.impact}
		if event.target == "region": event.target = regions[random.randi_range(0,regions.size()-1)].id
		elif event.target == "sea_route": event.target = sea_routes[random.randi_range(0,sea_routes.size()-1)].duplicate()
		content.events.events.append(event)
	var error: String = Content.validate(content,regions,connections)
	return {"error":error,"content":content} if error.is_empty() else {"error":error}

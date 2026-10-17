extends RefCounted
## JSON only: rebuild definitions from packaged content, validate before replacing a world.
const World = preload("res://scripts/simulation/world.gd")
const SLOTS = ["slot1", "slot2", "slot3", "auto"]
const MAX_BYTES = 2097152
# Trusted 0.7 builds: shipped mixed line endings, LF and CRLF. See tests/fixtures.
const LEGACY_07_HASHES = ["0285d7ef5812b9c4df607215fad53b9266dfff0b74cc0d661b6ccf4c6f132d19", "10c7d2193c11a8db4fcbc136af2244af17cdf7482ca893586cc3edc8f7e06d2b", "0cb9cea463f2a6883e28c3024475f26e7c7eda527db69a3074cc1c580305e829"]
const LEGACY_07_UPGRADES = ["transmission", "mobility", "discretion", "polar", "seasonal", "resilience"]
const LEGACY_08_HASH = "7030c81500cac55fcb5656cc286cf0f965a559f3c4f8e0cee8df54b9cfd67b19"
const LEGACY_09_HASH = "ae93560e93e6e89e97c7efb0d0ed393f0338bfb3127088cf58fb4c06197655a9"
const LEGACY_10_HASH = "f62d5506dcce2d68eec5c590a3efaf3e7b0bf8ef4f406486451afcfd317d19db"
const LEGACY_11_HASH = "4a65420bb3bcc4320c2925410f3c125ca40c4070260e55349df6328639ac93e6"
var directory = "user://saves/transports-1"

func content_hash() -> String:
	var text = ""
	for path in ["regions", "evolutions", "events", "scenarios", "transports", "objectives", "decisions", "decisions-0.11"]:
		text += FileAccess.get_file_as_string("res://data/%s.json" % path).replace("\r\n", "\n")
	return text.sha256_text()
func expanded_hash() -> String:
	return (content_hash()+"\n"+FileAccess.get_file_as_string(World.Expanded.PATH).replace("\r\n","\n")).sha256_text()
func crises_hash() -> String:
	return (expanded_hash()+"\n"+FileAccess.get_file_as_string(World.Crises.PATH).replace("\r\n","\n")).sha256_text()

func encode(world: RefCounted, selected: int = 0, speed: int = 1) -> Dictionary:
	if world.regions.is_empty(): return {}
	var states: Array = []
	for region in world.regions:
		states.append({"id": region.id, "healthy": region.healthy, "active": region.active, "removed": region.removed, "detected": region.detected})
	var effects: Array = []
	for effect in world.active_events:
		effects.append({"id": effect.id, "start_day": effect.start_day, "end_day": effect.end_day})
	var data = {"format": 5 if world.expanded_content else 4, "content": expanded_hash() if world.expanded_content else content_hash(), "engine": Engine.get_version_info().string,"decision_profile":world.decision_profile,
		"saved_at": Time.get_datetime_string_from_system(), "scenario": world.scenario.id,
		"difficulty": world.difficulty.id, "start": world.start_region_id,
		"day": world.day, "points": world.points, "cure": PackedFloat64Array([world.cure]).to_byte_array().hex_encode(), "outcome": world.outcome,
		"regions": states, "purchased": world.purchased.duplicate(), "journal": world.journal.duplicate(), "objective":world.objective.duplicate(true), "decision":world.decision.duplicate(true),
		"events": effects, "activated": world.activated_events.duplicate(), "phase": world.phase.id,
		"seed": str(world.rng.seed), "rng": str(world.rng.state),
		"selected": world.regions[clampi(selected, 0, world.regions.size() - 1)].id, "speed": speed,
		"history":world.history.duplicate(true),"purchase_history":world.purchase_history.duplicate(true)}
	if world.expanded_content: data["rules_profile"] = World.Expanded.PROFILE
	if world.crises_enabled:
		data.format = 6
		data.content = crises_hash()
		data.rules_profile = World.Crises.PROFILE
	return data

func _integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= minimum and value <= maximum

func _strings(value: Variant, maximum: int) -> bool:
	if not value is Array or value.size() > maximum: return false
	for item in value:
		if not item is String or item.length() > 2000: return false
	return true

func decode(data: Variant) -> Dictionary:
	var invalid = {"error": "Fichier de sauvegarde invalide."}
	if not data is Dictionary: return invalid
	for key in ["format", "content", "engine"]:
		if not data.has(key): return invalid
	var legacy = data.get("content") in LEGACY_07_HASHES
	var old_format = data.get("format") == 1 and (legacy or data.get("content") == LEGACY_08_HASH)
	var legacy09 = data.get("format") == 2 and data.get("content") == LEGACY_09_HASH
	var legacy10 = data.get("format") == 2 and data.get("content") == LEGACY_10_HASH
	var legacy11 = data.get("format") == 3 and data.get("content") == LEGACY_11_HASH
	var enriched = data.get("format") == 5 and data.get("content") == expanded_hash()
	var crises = data.get("format") == 6 and data.get("content") == crises_hash()
	var current_format = (data.get("format") == 4 and data.get("content") == content_hash()) or enriched or crises
	if (not old_format and not current_format and not legacy09 and not legacy10 and not legacy11) or data.get("engine") != Engine.get_version_info().string:
		return {"error": "Sauvegarde incompatible avec cette version du jeu.", "incompatible": true}
	if enriched and data.get("rules_profile") != World.Expanded.PROFILE: return invalid
	if crises and data.get("rules_profile") != World.Crises.PROFILE: return invalid
	if not enriched and not crises and data.has("rules_profile"): return invalid
	if not current_format and not legacy11 and data.has("decision"): return invalid
	if not current_format and data.has("decision_profile"): return invalid
	if old_format and data.has("objective"): return invalid
	if legacy09 and (not data.get("objective") is Dictionary or data.objective.get("id","") not in ["","first_relays"]): return invalid
	for key in ["scenario", "difficulty", "start", "phase", "outcome", "selected", "saved_at", "seed", "rng"]:
		if not data.get(key) is String or data[key].length() > 100: return invalid
	for key in ["seed", "rng"]:
		if not data[key].is_valid_int() or str(data[key].to_int()) != data[key]: return invalid
	if not _integer(data.get("day"), 0, 100000) or not _integer(data.get("points"), 0, 100000): return invalid
	# Decimal JSON round-trips can change the last bit: retain the exact IEEE-754 bytes.
	if not data.get("cure") is String or data.cure.length() != 16: return invalid
	for character in data.cure:
		if character not in "0123456789abcdef": return invalid
	var cure_bytes: PackedByteArray = data.cure.hex_decode()
	if cure_bytes.size() != 8 or cure_bytes.hex_encode() != data.cure: return invalid
	var cure_value = cure_bytes.to_float64_array()[0]
	if not is_finite(cure_value) or cure_value < 0 or cure_value > 100: return invalid
	if not _integer(data.get("speed"), 1, 4) or int(data.speed) not in [1, 2, 4]: return invalid
	if not _strings(data.get("purchased"), 100) or not _strings(data.get("journal"), 10000) or not _strings(data.get("activated"), 200): return invalid
	var world = World.new()
	if not world.start(data.start, data.seed.to_int(), null, null, data.scenario, data.difficulty,null,null,"",false,enriched or crises,null,crises).is_empty(): return invalid
	if not data.get("regions") is Array or data.regions.size() != world.regions.size(): return invalid
	var ids: Array = []
	for i in range(world.regions.size()):
		var state = data.regions[i]
		var region = world.regions[i]
		if not state is Dictionary or state.get("id") != region.id or not state.get("detected") is bool: return invalid
		for key in ["healthy", "active", "removed"]:
			if not _integer(state.get(key), 0, int(region.population)): return invalid
		if state.healthy + state.active + state.removed != region.population: return invalid
		for key in ["healthy", "active", "removed"]: region[key] = int(state[key])
		region.detected = state.detected
		ids.append(region.id)
	if data.selected not in ids: return invalid
	var spent = 0
	for id in data.purchased:
		if not world.evolutions.has(id) or id in world.purchased: return invalid
		if legacy and id not in LEGACY_07_UPGRADES: return invalid
		for excluded in world.evolutions[id].get("excludes", []):
			if excluded in world.purchased: return invalid
		for required in world.evolutions[id].requires:
			if required not in world.purchased: return invalid
		spent += int(world.evolutions[id].cost)
		world.purchased.append(id)
	world.day = int(data.day)
	world.points = int(data.points)
	world.cure = cure_value
	for candidate in world.scenario.phases:
		if candidate.start_day <= world.day: world.phase = candidate.duplicate(true)
	if data.phase != world.phase.id: return invalid
	var definitions: Dictionary = {}
	for definition in world.event_definitions: definitions[definition.id] = definition
	for region in world.regions:
		if region.detected:
			var id = "reaction_" + region.id
			definitions[id] = {"id": id, "name": "Réaction de " + region.name, "kind": "growth_multiplier", "target": region.id, "factor": world.detection_rules.reaction_factor, "duration": world.detection_rules.reaction_duration}
			if id not in data.activated: return invalid
	for id in data.activated:
		if not definitions.has(id) or id in world.activated_events: return invalid
		world.activated_events.append(id)
	for definition in world.event_definitions:
		if definition.start_day <= world.day and definition.id not in world.activated_events: return invalid
	if not data.get("events") is Array or data.events.size() > definitions.size(): return invalid
	var effect_ids: Array = []
	for effect in data.events:
		if not effect is Dictionary or not effect.get("id") is String: return invalid
		if effect.id not in world.activated_events or effect.id in effect_ids: return invalid
		if not _integer(effect.get("start_day"), 0, world.day) or not _integer(effect.get("end_day"), world.day + 1, 100100): return invalid
		var definition = definitions[effect.id].duplicate(true)
		if effect.end_day != effect.start_day + definition.duration: return invalid
		if definition.has("start_day") and effect.start_day != definition.start_day: return invalid
		definition.start_day = int(effect.start_day)
		definition.end_day = int(effect.end_day)
		world.active_events.append(definition)
		effect_ids.append(effect.id)
	for definition in world.event_definitions:
		if definition.start_day <= world.day and world.day < definition.start_day + definition.duration and definition.id not in effect_ids: return invalid
	world.journal.assign(data.journal)
	world.rng.seed = data.seed.to_int()
	world.rng.state = data.rng.to_int()
	var expected = ""
	if world.cure >= 100: expected = "defeat_cure"
	elif world.coverage() >= 0.9: expected = "victory"
	elif world.totals().active == 0: expected = "defeat_extinction"
	if data.outcome != expected: return invalid
	world.outcome = expected
	if current_format or legacy09 or legacy10 or legacy11:
		if not World.Objectives.valid_state(data.get("objective"), world): return invalid
		world.objective = data.objective.duplicate(true)
		if not world.objective.is_empty():
			world.objective.progress = int(world.objective.progress)
			world.objective.resolved_day = int(world.objective.resolved_day)
			if world.objective.has("routes"):
				for target in world.objective.routes: world.objective.routes[target] = int(world.objective.routes[target])
	if current_format or legacy11:
		var profile = data.get("decision_profile") if current_format else ("0.11" if data.get("decision") is Dictionary and not data.decision.is_empty() else "")
		if profile not in ["","0.11","0.12"]: return invalid
		if not data.get("decision") is Dictionary or (data.decision.is_empty() != (profile == "")): return invalid
		world.decision_profile = profile
		world.decision_rules = World.Decisions.legacy_definition() if profile == "0.11" else (World.Decisions.definition() if profile == "0.12" else {})
		if profile != "" and world.decision_rules.is_empty(): return invalid
		if not World.Decisions.valid_state(data.get("decision"),world): return invalid
		world.decision = data.decision.duplicate(true)
		if not world.decision.is_empty():
			world.decision.day = int(world.decision.day)
			if not world.decision.choice.is_empty(): spent += int(World.Decisions.option(world.decision.choice,world).cost)
	if int(data.points) != 8 + int(data.day / 5) * 3 - spent: return invalid
	if not World.History.restore(world,data): return invalid
	var result = {"error": "", "world": world, "selected": ids.find(data.selected), "speed": int(data.speed), "saved_at": data.saved_at}
	if legacy: result["warning"] = "Partie 0.7 chargée en pause ; nouvelles spécialisations disponibles."
	elif old_format: result["warning"] = "Partie 0.8 chargée en pause, sans objectif facultatif."
	elif legacy09: result["warning"] = "Partie 0.9 chargée en pause ; objectif facultatif conservé."
	elif legacy10: result["warning"] = "Partie 0.10 chargée en pause, sans nouvel événement à choix."
	elif legacy11: result["warning"] = "Partie 0.11 chargée en pause ; soutien conservé à 6 points."
	return result

func _path(slot: String) -> String:
	return directory.path_join(slot + ".json")

func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {"error": "Emplacement vide."}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null: return {"error": "Lecture impossible."}
	if file.get_length() > MAX_BYTES: return {"error": "Fichier trop volumineux."}
	var json = JSON.new()
	if json.parse(file.get_as_text()) != OK: return {"error": "Fichier JSON endommagé."}
	return decode(json.data)

func load_slot(slot: String) -> Dictionary:
	if slot not in SLOTS: return {"error": "Emplacement inconnu."}
	var primary = _read(_path(slot))
	if primary.error.is_empty() or primary.get("incompatible", false): return primary
	var backup = _read(_path(slot) + ".bak")
	if backup.error.is_empty():
		backup["backup"] = true
		backup["warning"] = "Copie de secours chargée ; le fichier principal est absent ou invalide. " + backup.get("warning", "")
		return backup
	return primary

func _write(path: String, text: String) -> String:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null: return "Impossible d'écrire la sauvegarde."
	file.store_string(text)
	file.flush()
	var error = file.get_error()
	file.close()
	return "" if error == OK else "Écriture incomplète ; ancienne sauvegarde conservée."

func save_slot(slot: String, world: RefCounted, selected: int = 0, speed: int = 1) -> String:
	if slot not in SLOTS: return "Emplacement inconnu."
	var data = encode(world, selected, speed)
	var validation = decode(data)
	if not validation.error.is_empty(): return validation.error
	var path = _path(slot)
	var previous = _read(path)
	if previous.get("incompatible", false): return previous.error
	if DirAccess.make_dir_recursive_absolute(directory) != OK: return "Dossier de sauvegarde inaccessible."
	var error = _write(path + ".tmp", JSON.stringify(data, "", true, true))
	if not error.is_empty(): return error
	if not _read(path + ".tmp").error.is_empty(): return "Vérification de l'écriture impossible."
	# Never replace a valid backup with corrupt input. Rename on the same volume.
	if previous.error.is_empty():
		error = _write(path + ".bak.tmp", FileAccess.get_file_as_string(path))
		if not error.is_empty(): return error
		if not _read(path + ".bak.tmp").error.is_empty(): return "Copie de secours invalide."
		if DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak") != OK: return "Impossible de conserver la copie de secours."
	if DirAccess.rename_absolute(path + ".tmp", path) != OK: return "Remplacement impossible ; ancienne sauvegarde conservée."
	return ""

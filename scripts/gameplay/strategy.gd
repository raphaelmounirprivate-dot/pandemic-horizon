extends RefCounted
## Optional rulesets. Decisions are a bounded ledger; no presentation state or extra RNG.
## strategy-0.25 is frozen (format 8); strategy-0.26 adds world-driven crises (format 9).
const PATH = "res://data/strategy-0.25.json"
const PROFILE = "strategy-0.25"
const CURRENT = "strategy-0.26"
const PATHS = {"strategy-0.25": PATH, "strategy-0.26": "res://data/strategy-0.26.json"}
const FORMATS = {"strategy-0.25": 8, "strategy-0.26": 9}
const CRISES = ["coordination", "cut", "science", "saturated", "passage"]
static var cached: Dictionary = {}

static func rules(profile: String = CURRENT) -> Dictionary:
	if not cached.has(profile) and PATHS.has(profile):
		var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATHS[profile]))
		if value is Dictionary: cached[profile] = value
	return cached.get(profile, {})

static func profile_of(world: RefCounted) -> String:
	return str(world.strategy.get("profile", PROFILE))

static func rules_of(world: RefCounted) -> Dictionary:
	return rules(profile_of(world))

static func modern(world: RefCounted) -> bool:
	return not world.strategy.is_empty() and profile_of(world) != PROFILE

static func validate(data: Variant) -> String:
	if not data is Dictionary or not PATHS.has(data.get("profile")) or data.get("schema_version") != (1 if data.profile == PROFILE else 2): return "Profil stratégique invalide."
	for key: String in ["day_seconds", "first_decision", "interval", "window", "duration", "last_decision", "base_exchange", "mobility_factor"]:
		var value: Variant = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or value <= 0: return "Paramètre stratégique invalide : " + key
	for key: String in ["first_decision", "interval", "window", "duration", "last_decision"]:
		if data[key] != floor(data[key]): return "Calendrier stratégique non entier."
	if data.window >= data.interval or data.duration >= data.interval or data.last_decision > 1000 or data.first_decision > data.last_decision: return "Calendrier stratégique incohérent."
	if not data.get("agents") is Dictionary or data.agents.size() != 3: return "Agents stratégiques absents."
	for id: String in ["nacre", "pulse", "veil"]:
		var agent: Variant = data.agents.get(id)
		if not agent is Dictionary or not agent.get("name") is String or not agent.get("description") is String: return "Agent stratégique invalide."
		var keys: Array = {"nacre":["threshold", "export"], "pulse":["period", "burst", "high", "low"], "veil":["hidden", "detected"]}[id]
		for key: String in keys:
			var value: Variant = agent.get(key)
			if not (value is int or value is float) or not is_finite(float(value)) or value <= 0 or value > 20: return "Mécanique d'agent invalide."
	if data.agents.nacre.threshold > 1 or data.agents.pulse.burst >= data.agents.pulse.period or data.agents.pulse.period != floor(data.agents.pulse.period) or data.agents.pulse.burst != floor(data.agents.pulse.burst): return "Cycle d'agent invalide."
	if data.profile == PROFILE: return validate_choices(data.get("choices"), ["anchor", "surge", "observe"])
	if data.agents.pulse.period == data.interval: return "Le cycle d'ONDE doit se décaler par rapport aux décisions."
	if data.has("mobility_cure") and (not ratio(data.mobility_cure) or not data.get("mobility_description") is String): return "Contrepartie de Mobilité invalide."
	var veil: Dictionary = data.agents.veil
	if (veil.has("detection") and not ratio(veil.detection)) or (veil.has("discretion_cost") and not integer(veil.discretion_cost, 1, 30)): return "Levier de VOILE invalide."
	var discretion: Variant = data.get("discretion")
	if not discretion is Dictionary or not discretion.get("description") is String or not integer(discretion.get("days"), 1, 200): return "Discrétion stratégique invalide."
	for key: String in ["cure", "exchange", "detection"]:
		if not ratio(discretion.get(key)): return "Discrétion stratégique invalide."
	var triggers: Variant = data.get("triggers")
	if not triggers is Dictionary or not ratio(triggers.get("saturated")) or triggers.saturated > 1 or not integer(triggers.get("science"), 1, 99) or not integer(triggers.get("passage"), 1, 100000): return "Déclencheurs de crise invalides."
	if not data.get("crises") is Array or data.crises.size() != CRISES.size(): return "Crises stratégiques absentes."
	for index: int in range(CRISES.size()):
		var crisis: Variant = data.crises[index]
		if not crisis is Dictionary or crisis.get("id") != CRISES[index] or not crisis.get("name") is String or not crisis.get("description") is String: return "Crise stratégique invalide."
		var error: String = validate_choices(crisis.get("choices"), [])
		if not error.is_empty(): return error
	return ""

static func ratio(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value > 0 and value <= 5

static func validate_choices(choices: Variant, expected: Array) -> String:
	if not choices is Array or choices.size() != 3: return "Choix stratégiques absents."
	var ids: Array = []
	for item: Variant in choices:
		if not item is Dictionary or not item.get("id") is String or item.id in ids or (not expected.is_empty() and item.id not in expected): return "Choix stratégique invalide."
		if not item.get("name") is String or not item.get("description") is String: return "Texte stratégique absent."
		if not integer(item.get("cost"), 0, 20): return "Coût stratégique invalide."
		for key: String in ["growth", "exchange", "cure"]:
			if not ratio(item.get(key)): return "Effet stratégique invalide."
		if item.has("target_growth") and not ratio(item.target_growth): return "Effet stratégique invalide."
		if item.id == "observe" and (item.cost != 0 or item.growth != 1 or item.exchange != 1 or item.cure != 1 or item.has("target_growth")): return "Le choix par défaut doit rester neutre."
		ids.append(item.id)
	return "" if "observe" in ids else "Choix par défaut absent."

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= minimum and value <= maximum

static func initial(agent: String, profile: String = PROFILE) -> Dictionary:
	if profile == PROFILE: return {"agent":agent, "choices":[]}
	return {"profile":profile, "agent":agent, "choices":[], "open":{}}

static func slot(day: int, data: Dictionary = rules(PROFILE)) -> int:
	if day < data.first_decision: return -1
	return int(data.first_decision) + int((day - int(data.first_decision)) / int(data.interval)) * int(data.interval)

static func slot_of(world: RefCounted) -> int:
	return slot(world.day, rules_of(world))

static func pending(world: RefCounted) -> bool:
	if world.strategy.is_empty() or not world.outcome.is_empty(): return false
	if modern(world): return not world.strategy.open.is_empty()
	var opened: int = slot(world.day)
	if opened < 0 or opened > rules(PROFILE).last_decision or world.day >= opened + rules(PROFILE).window: return false
	return world.strategy.choices.is_empty() or world.strategy.choices[-1].slot != opened

static func crisis(data: Dictionary, id: String) -> Dictionary:
	for item: Dictionary in data.get("crises", []):
		if item.id == id: return item
	return {}

## Choices offered now (or for the given ledger entry); 0.25 always offers the same three.
static func choices(world: RefCounted, entry: Dictionary = {}) -> Array:
	if not modern(world): return rules(PROFILE).choices
	var source: Dictionary = entry if not entry.is_empty() else world.strategy.open
	return crisis(rules_of(world), str(source.get("crisis", "coordination"))).get("choices", [])

static func option(id: String, world: RefCounted = null, entry: Dictionary = {}) -> Dictionary:
	for item: Dictionary in (rules(PROFILE).choices if world == null else choices(world, entry)):
		if item.id == id: return item
	return {}

static func choose(world: RefCounted, id: String) -> String:
	if not pending(world): return "Aucune décision stratégique en attente."
	var item: Dictionary = option(id, world)
	if item.is_empty(): return "Choix stratégique inconnu."
	if world.points < item.cost: return "Points insuffisants : %d requis." % item.cost
	world.points -= int(item.cost)
	if modern(world):
		var open: Dictionary = world.strategy.open
		world.strategy.choices.append({"slot":open.slot, "day":world.day, "choice":id, "crisis":open.crisis, "target":open.target})
		world.strategy.open = {}
	else:
		world.strategy.choices.append({"slot":slot(world.day), "day":world.day, "choice":id})
	world.journal.append("Jour %d · Stratégie : %s (%d points). %s" % [world.day, item.name, item.cost, item.description])
	world.History.record(world)
	return ""

static func update(world: RefCounted) -> void:
	if world.strategy.is_empty(): return
	if modern(world): return update_modern(world)
	var opened: int = slot(world.day)
	if opened < 0 or opened > rules(PROFILE).last_decision: return
	if world.day == opened: world.journal.append("Jour %d · Crise de coordination : choisir une stratégie [F2]." % world.day)
	if world.day == opened + rules(PROFILE).window and (world.strategy.choices.is_empty() or world.strategy.choices[-1].slot != opened):
		world.strategy.choices.append({"slot":opened, "day":world.day, "choice":"observe"})
		world.journal.append("Jour %d · Stratégie : conservation gratuite des points (échéance)." % world.day)

static func update_modern(world: RefCounted) -> void:
	var data: Dictionary = rules_of(world)
	var opened: int = slot(world.day, data)
	if opened < 0 or opened > data.last_decision: return
	if world.day == opened:
		var found: Dictionary = detect_crisis(world)
		world.strategy.open = {"slot":opened, "crisis":found.crisis, "target":found.target}
		var item: Dictionary = crisis(data, found.crisis)
		world.journal.append("Jour %d · %s%s : choisir une stratégie [F2]." % [world.day, item.name, "" if found.target.is_empty() else " (" + world.region_name(found.target) + ")"])
	if world.day == opened + data.window and not world.strategy.open.is_empty():
		var open: Dictionary = world.strategy.open
		world.strategy.choices.append({"slot":open.slot, "day":world.day, "choice":"observe", "crisis":open.crisis, "target":open.target})
		world.strategy.open = {}
		world.journal.append("Jour %d · Stratégie : conservation gratuite des points (échéance)." % world.day)

## Reads the state left by the previous day, in region order: deterministic, no RNG.
static func detect_crisis(world: RefCounted) -> Dictionary:
	var triggers: Dictionary = rules_of(world).triggers
	var found: Dictionary = {}
	# A touched region with at least one closed link (storm, inspection, incident).
	for region: Dictionary in world.regions:
		if region.active <= 0 or found.has("cut"): continue
		for edge: Array in world.connections:
			if region.id in edge and not world.route_is_open(edge): found["cut"] = region.id
	if world.cure >= float(triggers.science): found["science"] = ""
	for region: Dictionary in world.regions:
		if not found.has("saturated") and float(region.active + region.removed) / region.population >= triggers.saturated: found["saturated"] = region.id
	for edge: Array in world.connections:
		if found.has("passage") or not world.route_is_open(edge): continue
		for pair: Array in [[edge[0], edge[1]], [edge[1], edge[0]]]:
			var source: Dictionary = region_by_id(world, pair[0])
			var target: Dictionary = region_by_id(world, pair[1])
			if not found.has("passage") and source.active >= int(triggers.passage) and target.active + target.removed == 0: found["passage"] = target.id
	# Avoid offering the same situation twice in a row when another one applies.
	var previous: String = str(world.strategy.choices[-1].crisis) if not world.strategy.choices.is_empty() else ""
	for id: String in ["cut", "science", "saturated", "passage"]:
		if found.has(id) and id != previous: return {"crisis":id, "target":found[id]}
	return {"crisis":"coordination", "target":""}

static func region_by_id(world: RefCounted, id: String) -> Dictionary:
	for region: Dictionary in world.regions:
		if region.id == id: return region
	return {}

## Latest ledger entry while its effect is running, else empty.
static func running(world: RefCounted) -> Dictionary:
	if world.strategy.is_empty() or world.strategy.choices.is_empty(): return {}
	var latest: Dictionary = world.strategy.choices[-1]
	if world.day <= latest.day or world.day > latest.day + rules_of(world).duration: return {}
	return latest

static func factor(world: RefCounted, kind: String) -> float:
	var latest: Dictionary = running(world)
	if latest.is_empty(): return 1.0
	if not modern(world): return float(option(latest.choice).get(kind, 1.0))
	return float(option(latest.choice, world, latest).get(kind, 1.0))

## Last day on which the 0.26 Discrétion effect applies, or -1.
static func discretion_end(world: RefCounted) -> int:
	if not modern(world) or "discretion" not in world.purchased: return -1
	for item: Dictionary in world.purchase_history:
		if item.id == "discretion": return int(item.day) + int(rules_of(world).discretion.days)
	return -1

static func discretion_active(world: RefCounted) -> bool:
	return world.day <= discretion_end(world)

## 0.26 replaces the permanent Discrétion cure bonus by a temporary one.
static func cure(world: RefCounted) -> float:
	var result: float = factor(world, "cure")
	if modern(world) and "discretion" in world.purchased:
		var base: float = float(world.evolutions.discretion.modifiers.get("cure_multiplier", 1.0))
		result *= (float(rules_of(world).discretion.cure) if discretion_active(world) else 1.0) / base
	# Optional Mobilité counterpart; absent means exactly neutral.
	if modern(world) and "mobility" in world.purchased and rules_of(world).has("mobility_cure"): result *= float(rules_of(world).mobility_cure)
	return result

static func detection(world: RefCounted) -> float:
	if not modern(world): return 1.0
	var data: Dictionary = rules_of(world)
	var result: float = float(data.agents.veil.get("detection", 1.0)) if world.strategy.agent == "veil" else 1.0
	if discretion_active(world): result *= float(data.discretion.detection)
	return result

## Profile-specific evolution costs, applied once at start (and again when a save is rebuilt).
static func prepare(world: RefCounted) -> void:
	if modern(world) and world.strategy.agent == "veil" and rules_of(world).agents.veil.has("discretion_cost"):
		world.evolutions.discretion.cost = int(rules_of(world).agents.veil.discretion_cost)

static func pulse_high(world: RefCounted, day: int) -> bool:
	var agent: Dictionary = rules_of(world).agents.pulse
	return day % int(agent.period) < agent.burst

static func growth(world: RefCounted, region: Dictionary) -> float:
	if world.strategy.is_empty(): return 1.0
	var id: String = world.strategy.agent
	var agent: Dictionary = rules_of(world).agents[id]
	var result: float = factor(world, "growth")
	if id == "pulse": result *= float(agent.high if pulse_high(world, world.day) else agent.low)
	if id == "veil": result *= float(agent.detected if region.detected else agent.hidden)
	var latest: Dictionary = running(world)
	if modern(world) and not latest.is_empty() and latest.target == region.id: result *= float(option(latest.choice, world, latest).get("target_growth", 1.0))
	return result

static func exchange(world: RefCounted, source: Dictionary) -> float:
	if world.strategy.is_empty(): return 1.0
	var data: Dictionary = rules_of(world)
	var result: float = float(data.base_exchange) * factor(world, "exchange")
	if "mobility" in world.purchased: result *= float(data.mobility_factor)
	var agent: Dictionary = data.agents.nacre
	if world.strategy.agent == "nacre" and float(source.active + source.removed) / source.population >= agent.threshold: result *= float(agent.export)
	if discretion_active(world): result *= float(data.discretion.exchange)
	return result

static func spent(world: RefCounted) -> int:
	var total: int = 0
	if not world.strategy.is_empty():
		for item: Dictionary in world.strategy.choices: total += int(option(item.choice, world, item).cost)
	return total

static func restore(world: RefCounted, state: Variant) -> bool:
	if not state is Dictionary or state.get("agent") not in rules(PROFILE).agents or not state.get("choices") is Array or state.choices.size() > 100: return false
	var profile: String = str(state.get("profile", PROFILE))
	if profile != profile_of(world) or state.size() != (2 if profile == PROFILE else 4): return false
	var data: Dictionary = rules(profile)
	var keys: int = 3 if profile == PROFILE else 5
	var expected: int = int(data.first_decision)
	var previous: String = ""
	for item: Variant in state.choices:
		if not item is Dictionary or item.size() != keys or not integer(item.get("slot"), expected, expected) or expected > data.last_decision: return false
		if not integer(item.get("day"), expected, mini(world.day, expected + int(data.window))): return false
		if profile != PROFILE and not valid_situation(world, item, previous): return false
		if option(str(item.get("choice", "")), null if profile == PROFILE else world, item if profile != PROFILE else {}).is_empty(): return false
		if item.day == expected + data.window and item.choice != "observe": return false
		previous = str(item.get("crisis", ""))
		expected += int(data.interval)
	if profile != PROFILE:
		var open: Variant = state.get("open")
		var waiting: bool = expected <= data.last_decision and world.day >= expected and world.day < expected + data.window
		if not open is Dictionary or open.is_empty() == waiting: return false
		if waiting and (open.size() != 3 or not integer(open.get("slot"), expected, expected) or not valid_situation(world, open, previous)): return false
		if waiting: expected += int(data.interval)
	if expected <= data.last_decision and world.day >= expected + data.window: return false
	world.strategy = state.duplicate(true)
	for item: Dictionary in world.strategy.choices:
		item.slot = int(item.slot)
		item.day = int(item.day)
	if world.strategy.has("open") and not world.strategy.open.is_empty(): world.strategy.open.slot = int(world.strategy.open.slot)
	return true

static func valid_situation(world: RefCounted, item: Dictionary, previous: String) -> bool:
	var id: Variant = item.get("crisis")
	var target: Variant = item.get("target")
	if id not in CRISES or not target is String or (id != "coordination" and id == previous): return false
	if id in ["coordination", "science"]: return target.is_empty()
	return not region_by_id(world, target).is_empty()

static func summary(world: RefCounted) -> String:
	if world.strategy.is_empty(): return ""
	var data: Dictionary = rules_of(world)
	var agent: Dictionary = data.agents[world.strategy.agent]
	var opened: int = slot(world.day, data)
	var next: int = int(data.first_decision) if world.day < data.first_decision else opened + int(data.interval)
	var title: String = ""
	if modern(world) and pending(world):
		var open: Dictionary = world.strategy.open
		title = crisis(data, open.crisis).name + ("" if open.target.is_empty() else " (" + world.region_name(open.target) + ")") + " · "
	return "%s · %s" % [agent.name, title + ("Décision avant J%d [F2]" % (opened + int(data.window) - 1) if pending(world) else ("Prochaine décision J%d" % next if next <= data.last_decision else "Toutes les crises ont été proposées"))]

static func situation_text(world: RefCounted) -> String:
	if not modern(world) or world.strategy.open.is_empty(): return ""
	return crisis(rules_of(world), world.strategy.open.crisis).description

## Readable state of every running strategic effect, with days left.
static func active_lines(world: RefCounted) -> Array[String]:
	var lines: Array[String] = []
	if world.strategy.is_empty(): return lines
	var data: Dictionary = rules_of(world)
	# Upcoming days of effect: the choice day itself shows the full duration.
	var latest: Dictionary = {} if world.strategy.choices.is_empty() else world.strategy.choices[-1]
	var left: int = 0 if latest.is_empty() else latest.day + int(data.duration) - world.day
	if left > 0 and latest.choice != "observe":
		var item: Dictionary = option(latest.choice, world, latest) if modern(world) else option(latest.choice)
		var target: String = str(latest.get("target", ""))
		var local: String = "" if target.is_empty() or not item.has("target_growth") else " · %s ×%s" % [world.region_name(target), number(item.target_growth)]
		lines.append("Stratégie : %s · croissance ×%s · échanges ×%s · remède ×%s%s · %d j restants" % [item.name, number(item.growth), number(item.exchange), number(item.cure), local, mini(left, int(data.duration))])
	if world.strategy.agent == "pulse":
		var agent: Dictionary = data.agents.pulse
		var high: bool = pulse_high(world, world.day + 1)
		var span: int = 0
		while pulse_high(world, world.day + span + 1) == high: span += 1
		lines.append("ONDE : %s ×%s encore %d j, puis %s dès J%d" % ["poussée" if high else "repli", number(agent.high if high else agent.low), span, "repli" if high else "poussée", world.day + span + 1])
	var left_discretion: int = discretion_end(world) - world.day
	if left_discretion > 0:
		lines.append("Discrétion : remède ×%s · seuil de détection ×%s · échanges ×%s · %d j restants" % [number(data.discretion.cure), number(data.discretion.detection), number(data.discretion.exchange), mini(left_discretion, int(data.discretion.days))])
	return lines

## One short always-visible line: running choice, ONDE phase and Discrétion, with days.
static func compact_line(world: RefCounted) -> String:
	if world.strategy.is_empty(): return ""
	var data: Dictionary = rules_of(world)
	var parts: Array[String] = []
	var latest: Dictionary = {} if world.strategy.choices.is_empty() else world.strategy.choices[-1]
	var left: int = 0 if latest.is_empty() else latest.day + int(data.duration) - world.day
	if left > 0 and latest.choice != "observe":
		var item: Dictionary = option(latest.choice, world, latest) if modern(world) else option(latest.choice)
		parts.append("%s : %d j" % [item.name, mini(left, int(data.duration))])
	if world.strategy.agent == "pulse":
		var high: bool = pulse_high(world, world.day + 1)
		var span: int = 0
		while pulse_high(world, world.day + span + 1) == high: span += 1
		parts.append("ONDE %s %d j → %s" % ["poussée" if high else "repli", span, "repli" if high else "poussée"])
	var discretion_days: int = discretion_end(world) - world.day
	if discretion_days > 0: parts.append("Discrétion : %d j" % mini(discretion_days, int(data.discretion.days)))
	return "" if parts.is_empty() else "En cours · " + " · ".join(parts)

## Evolution text shown to the player when this profile overrides it.
static func effect_text(world: RefCounted, id: String) -> String:
	if id == "discretion" and modern(world): return rules_of(world).discretion.description
	if id == "mobility" and modern(world) and rules_of(world).has("mobility_description"): return rules_of(world).mobility_description
	return str(world.evolutions[id].effect)

static func number(value: Variant) -> String:
	return ("%.2f" % float(value)).trim_suffix("0").trim_suffix("0").trim_suffix(".").replace(".", ",")

extends RefCounted
## Optional ruleset. Decisions are a bounded ledger; no presentation state or extra RNG.
const PATH = "res://data/strategy-0.25.json"
const PROFILE = "strategy-0.25"
static var cached: Dictionary = {}

static func rules() -> Dictionary:
	if cached.is_empty():
		var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if value is Dictionary: cached = value
	return cached

static func validate(data: Variant) -> String:
	if not data is Dictionary or data.get("schema_version") != 1 or data.get("profile") != PROFILE: return "Profil stratégique invalide."
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
	if not data.get("choices") is Array or data.choices.size() != 3: return "Choix stratégiques absents."
	var ids: Array = []
	for item: Variant in data.choices:
		if not item is Dictionary or item.get("id") not in ["anchor", "surge", "observe"] or item.id in ids: return "Choix stratégique invalide."
		if not item.get("name") is String or not item.get("description") is String: return "Texte stratégique absent."
		if not integer(item.get("cost"), 0, 20): return "Coût stratégique invalide."
		for key: String in ["growth", "exchange", "cure"]:
			var value: Variant = item.get(key)
			if not (value is int or value is float) or not is_finite(float(value)) or value <= 0 or value > 5: return "Effet stratégique invalide."
		if item.id == "observe" and (item.cost != 0 or item.growth != 1 or item.exchange != 1 or item.cure != 1): return "Le choix par défaut doit rester neutre."
		ids.append(item.id)
	return ""

static func integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value == floor(value) and value >= minimum and value <= maximum

static func initial(agent: String) -> Dictionary:
	return {"agent":agent, "choices":[]}

static func slot(day: int) -> int:
	var data: Dictionary = rules()
	if day < data.first_decision: return -1
	return int(data.first_decision) + int((day - int(data.first_decision)) / int(data.interval)) * int(data.interval)

static func pending(world: RefCounted) -> bool:
	if world.strategy.is_empty() or not world.outcome.is_empty(): return false
	var opened: int = slot(world.day)
	if opened < 0 or opened > rules().last_decision or world.day >= opened + rules().window: return false
	return world.strategy.choices.is_empty() or world.strategy.choices[-1].slot != opened

static func option(id: String) -> Dictionary:
	for item: Dictionary in rules().choices:
		if item.id == id: return item
	return {}

static func choose(world: RefCounted, id: String) -> String:
	if not pending(world): return "Aucune décision stratégique en attente."
	var item: Dictionary = option(id)
	if item.is_empty(): return "Choix stratégique inconnu."
	if world.points < item.cost: return "Points insuffisants : %d requis." % item.cost
	world.points -= int(item.cost)
	world.strategy.choices.append({"slot":slot(world.day), "day":world.day, "choice":id})
	world.journal.append("Jour %d · Stratégie : %s (%d points). %s" % [world.day, item.name, item.cost, item.description])
	world.History.record(world)
	return ""

static func update(world: RefCounted) -> void:
	if world.strategy.is_empty(): return
	var opened: int = slot(world.day)
	if opened < 0 or opened > rules().last_decision: return
	if world.day == opened: world.journal.append("Jour %d · Crise de coordination : choisir une stratégie [F2]." % world.day)
	if world.day == opened + rules().window and (world.strategy.choices.is_empty() or world.strategy.choices[-1].slot != opened):
		world.strategy.choices.append({"slot":opened, "day":world.day, "choice":"observe"})
		world.journal.append("Jour %d · Stratégie : conservation gratuite des points (échéance)." % world.day)

static func factor(world: RefCounted, kind: String) -> float:
	if world.strategy.is_empty() or world.strategy.choices.is_empty(): return 1.0
	var latest: Dictionary = world.strategy.choices[-1]
	if world.day <= latest.day or world.day > latest.day + rules().duration: return 1.0
	return float(option(latest.choice).get(kind, 1.0))

static func growth(world: RefCounted, region: Dictionary) -> float:
	if world.strategy.is_empty(): return 1.0
	var id: String = world.strategy.agent
	var agent: Dictionary = rules().agents[id]
	var result: float = factor(world, "growth")
	if id == "pulse": result *= float(agent.high if world.day % int(agent.period) < agent.burst else agent.low)
	if id == "veil": result *= float(agent.detected if region.detected else agent.hidden)
	return result

static func exchange(world: RefCounted, source: Dictionary) -> float:
	if world.strategy.is_empty(): return 1.0
	var result: float = float(rules().base_exchange) * factor(world, "exchange")
	if "mobility" in world.purchased: result *= float(rules().mobility_factor)
	var agent: Dictionary = rules().agents.nacre
	if world.strategy.agent == "nacre" and float(source.active + source.removed) / source.population >= agent.threshold: result *= float(agent.export)
	return result

static func spent(world: RefCounted) -> int:
	var total: int = 0
	if not world.strategy.is_empty():
		for item: Dictionary in world.strategy.choices: total += int(option(item.choice).cost)
	return total

static func restore(world: RefCounted, state: Variant) -> bool:
	if not state is Dictionary or state.size() != 2 or state.get("agent") not in rules().agents or not state.get("choices") is Array or state.choices.size() > 100: return false
	var expected: int = int(rules().first_decision)
	for item: Variant in state.choices:
		if not item is Dictionary or item.size() != 3 or not integer(item.get("slot"), expected, expected) or expected > rules().last_decision: return false
		if not integer(item.get("day"), expected, mini(world.day, expected + int(rules().window))) or option(str(item.get("choice", ""))).is_empty(): return false
		if item.day == expected + rules().window and item.choice != "observe": return false
		expected += int(rules().interval)
	if expected <= rules().last_decision and world.day >= expected + rules().window: return false
	world.strategy = state.duplicate(true)
	for item: Dictionary in world.strategy.choices:
		item.slot = int(item.slot)
		item.day = int(item.day)
	return true

static func summary(world: RefCounted) -> String:
	if world.strategy.is_empty(): return ""
	var agent: Dictionary = rules().agents[world.strategy.agent]
	var next: int = int(rules().first_decision) if world.day < rules().first_decision else slot(world.day) + int(rules().interval)
	return "%s · %s" % [agent.name, "Décision avant J%d [F2]" % (slot(world.day) + int(rules().window) - 1) if pending(world) else ("Prochaine décision J%d" % next if next <= rules().last_decision else "Toutes les crises ont été proposées")]

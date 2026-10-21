extends RefCounted
## Read-only presentation metadata. Does not change saved rules or purchase order.
const PATH = "res://data/skill-families.json"
const NAMES = {"growth_bonus":"Croissance","exchange_multiplier":"Échanges","cure_multiplier":"Remède","land_multiplier":"Terre","air_multiplier":"Air","sea_multiplier":"Mer","cold_multiplier":"Froid","seasonal_multiplier":"Saison","climate_penalty_multiplier":"Pénalité climat","incident_transport_penalty":"Pénalité transport","incident_research_penalty":"Surcroît remède","incident_growth_penalty":"Pénalité croissance"}
static func catalog() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH)).families
static func family(id: String) -> Dictionary:
	for group in catalog():
		if id in group.skills: return group
	return {}
static func ordered(world) -> Array:
	var result: Array = []
	for group in catalog():
		for id in group.skills:
			if world.evolutions.has(id): result.append(id)
	# Future content stays visible even if its presentation metadata is missing.
	for id in world.evolutions:
		if id not in result: result.append(id)
	return result
static func lineage(world,id: String) -> Array:
	var result: Array = []
	var pending: Array = [id]
	while not pending.is_empty():
		var current = pending.pop_back()
		if current in result or not world.evolutions.has(current): continue
		result.append(current)
		pending.append_array(world.evolutions[current].requires)
	return result
## One-line effect for a tree node, built from the modifiers ("Mer ×2,5 · Remède ×1,12").
static func short_effect(skill: Dictionary) -> String:
	var parts: Array[String] = []
	for key in skill.get("modifiers",{}):
		var value = float(skill.modifiers[key])
		if key == "growth_bonus": parts.append("Croissance +%s" % number(value*100))
		# Cure and incident factors are small: a signed percentage reads faster than ×1,04.
		elif key == "cure_multiplier" or key.begins_with("incident_"): parts.append("%s %s%s %%" % [NAMES.get(key,key),"+" if value > 1.0 else "−",number(absf(value-1.0)*100)])
		else: parts.append("%s ×%s" % [NAMES.get(key,key),number(value)])
	return " · ".join(parts)
static func number(value: float) -> String:
	var rounded = snappedf(value,0.01)
	if is_equal_approx(rounded,roundf(rounded)): return str(int(roundf(rounded)))
	return String.num(rounded,2).replace(".",",")
static func comparison(world,id: String) -> String:
	if not world.evolutions.has(id): return ""
	var skill = world.evolutions[id]
	var acquired = id in world.purchased
	var parts: Array[String] = []
	for key in skill.modifiers:
		var current = world.upgrade_modifier(key,0.22 if key == "growth_bonus" else 1.0)
		var after = current if acquired else (current+float(skill.modifiers[key]) if key == "growth_bonus" else current*float(skill.modifiers[key]))
		if key == "growth_bonus": parts.append("Croissance %.1f %% → %.1f %%" % [current*100,after*100])
		else: parts.append("%s ×%.2f → ×%.2f" % [NAMES.get(key,key),current,after])
	return " · ".join(parts)
static func details(world,id: String,reason: String) -> String:
	var group = family(id)
	var state = "Acquise" if id in world.purchased else ("Disponible" if reason.is_empty() else reason)
	return "%s · %s\n%s\n%s\nHors climat/aléas · %s" % [world.evolutions[id].name,group.get("name","Compétence"),world.Strategy.effect_text(world,id),comparison(world,id),state]

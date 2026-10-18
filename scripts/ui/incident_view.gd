extends RefCounted
## Read-only presentation of active incidents. Never inspect future definitions.
static func entries(world) -> Array:
	var result: Array = []
	for effect in world.active_events:
		if effect.get("source") != "crisis" or world.day < effect.start_day or world.day >= effect.end_day: continue
		var scope = "global"
		var label = "Monde · recherche"
		if effect.kind == "route_closure":
			scope = "route"
			label = "Liaison %s ↔ %s" % [world.region_name(effect.target[0]),world.region_name(effect.target[1])]
		elif effect.kind == "growth_multiplier":
			scope = "region"
			label = "Région " + world.region_name(effect.target)
		elif effect.kind == "transport_multiplier": label = "Monde · transport " + world.Transports.NAMES[effect.target].to_lower()
		result.append({"id":effect.id,"scope":scope,"target":effect.target,"template":effect.template,"impact":effect.impact,"text":"%s · %s\n%s · %d j restants (fin J%d)" % [effect.name,label,world.effect_description(effect),effect.end_day-world.day,effect.end_day],"start_day":effect.start_day})
	result.sort_custom(func(a,b): return a.id < b.id)
	return result
static func active_lines(world) -> Array[String]:
	var descriptions: Dictionary = {}
	for entry in entries(world): descriptions[entry.id] = entry.text
	var lines: Array[String] = []
	for entry in entries(world): lines.append(entry.text)
	for effect in world.active_events:
		if not descriptions.has(effect.id): lines.append("%s · %s · %d j restants" % [effect.name,world.effect_description(effect),effect.end_day-world.day])
	if world.decision.get("status") in ["pending","active"]: lines.append(world.Decisions.summary(world))
	return lines
static func counts(world) -> Dictionary:
	var result = {"local":0,"global":0}
	for entry in entries(world): result["global" if entry.scope == "global" else "local"] += 1
	return result
